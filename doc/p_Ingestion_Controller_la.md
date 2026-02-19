# p_Ingestion_Controller_la — Pipeline Documentation

**Azure Synapse Pipeline**  
High-level controller that loads data from BAIS and triggers data transformation for the Juror ER (Eric) ingestion flow.

---

## Overview

| Property | Value |
|----------|--------|
| **Pipeline name** | `p_Ingestion_Controller_la` |
| **Purpose** | Load data from BAIS → run ETL → copy to Juror DB → update watermark |
| **Concurrency** | 1 (single run at a time) |

---

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `folder` | string | `BAIS/Sites/External-In-Legacy/Juror_ER` | Source folder path in BAIS |
| `last_modified` | string | — | Optional watermark; when set, overrides metadata file |
| `source_container` | string | `juror-raw` | Container for raw/source data |
| `year_filter` | string | `2025` | Year filter for processing |
| `processing_container` | string | `qz-test` | Container for processed/intermediate data |
| `debug_mode` | string | `true` | Enables debug behavior in child ETL |
| `config_container` | string | `juror-etl` | Container for ETL configuration |
| `eric_voters_tmp_container` | string | `dl-juror-eric-voters-temp` | Temp container for ERIC voters data |

---

## Pipeline Variables

| Variable | Type | Description |
|----------|------|-------------|
| `yearFilter` | String | Resolved year used for filtering (from param or derived from current date) |
| `lastModified` | String | Watermark datetime used for incremental reads |

---

## Execution Flow (High Level)

```
Set Year Filter ──┐
                  ├──► If file exist ──► Execute ETL ──► Copy to JurorDB ──► update watermark
Get metadata files ─┘
```

---

## Step-by-Step Documentation

### 1. Set Year Filter

| Attribute | Value |
|-----------|--------|
| **Type** | Set Variable |
| **Depends on** | None (runs first) |

**What it does**  
Sets the pipeline variable `yearFilter` used for year-based filtering in the ETL.

**Logic**  
- If `pipeline().parameters.year_filter` is **not** empty → use it.
- Else:
  - If current month > September → use **next calendar year** (e.g. Oct 2025 → `2026`).
  - Otherwise → use **current year** (e.g. `2025`).

**Variable set**  
- `yearFilter` = computed year string.

---

### 2. Get metadata files

| Attribute | Value |
|-----------|--------|
| **Type** | Get Metadata |
| **Depends on** | None |
| **Dataset** | `DS_metadata_json` (metadata container, file: `landing.json`) |

**What it does**  
Checks whether the watermark metadata file `landing.json` exists in the metadata container.

**Output**  
- `exists` (boolean): whether the file is present.  
Used by **If file exist** to decide whether to read the last run time from metadata or use a default/parameter.

---

### 3. If file exist

| Attribute | Value |
|-----------|--------|
| **Type** | If Condition |
| **Depends on** | Get metadata files (Succeeded) |

**Condition**  
`@and(activity('Get metadata files').output.exists, empty(pipeline().parameters.last_modified))`

- **True branch**: metadata file exists **and** `last_modified` parameter is **empty** → use metadata for watermark.
- **False branch**: otherwise → use default or parameter for watermark.

**True branch activities**

- **Get Last Modified** (Lookup)  
  - Reads `landing.json` from the metadata container.  
  - Output is used to get `lastExecution` (last run timestamp).

- **Set last modified** (Set Variable)  
  - Depends on: Get Last Modified (Succeeded).  
  - Sets `lastModified` = `activity('Get Last Modified').output.value[0].lastExecution`.

**False branch activity**

- **Set default time** (Set Variable)  
  - Sets `lastModified` = `pipeline().parameters.last_modified` if provided; otherwise `'1900-01-01T00:00:00+01:00'`.

**Result**  
After this step, `lastModified` is always set for use in **Execute ETL** and **Copy to JurorDB**.

---

### 4. Execute ETL

| Attribute | Value |
|-----------|--------|
| **Type** | Execute Pipeline |
| **Depends on** | Set Year Filter (Succeeded), If file exist (Succeeded) |
| **Child pipeline** | `p_er_juror_eric_etl` |
| **Wait on completion** | Yes |

**What it does**  
Runs the Juror ERIC ETL pipeline that loads from BAIS and produces Parquet in the processing container.

**Parameters passed to child pipeline**

| Child parameter | Value / expression |
|-----------------|--------------------|
| `source_container` | `juror-la-landing` (fixed) |
| `year_filter` | `@variables('yearFilter')` |
| `processing_container` | `@pipeline().parameters.processing_container` |
| `debug_mode` | `@pipeline().parameters.debug_mode` |
| `config_container` | `@pipeline().parameters.config_container` |
| `eric_voters_tmp_container` | `@pipeline().parameters.eric_voters_tmp_container` |

---

### 5. Copy to JurorDB

| Attribute | Value |
|-----------|--------|
| **Type** | Copy |
| **Depends on** | Execute ETL (Succeeded) |
| **Timeout** | 30 minutes |
| **Retry** | 0 |

**What it does**  
Copies voter data from Data Lake (Parquet) to Juror DB (PostgreSQL), using the watermark so only relevant files are read.

**Source**

- **Dataset**: `DS_Lake_parquet`  
  - Container: `@pipeline().parameters.processing_container`  
  - Path pattern: `voters_postgresql/creation_date_partition=*/`  
  - Filter: `modifiedDatetimeStart` = `@variables('lastModified')`  
  - Format: Parquet, recursive read, no partition discovery.

**Sink**

- **Dataset**: `DS_juror_eric` (Azure PostgreSQL).
- **Write**: CopyCommand, batch size 1,000,000, batch timeout 30 minutes.
- **Staging**: Disabled.

**Column mapping (summary)**  
Maps Parquet columns to PostgreSQL with type conversion (e.g. string → `character varying`, INT96 → `date`, string → `bigint` for `hash_id`). Main fields include: `part_no`, `register_lett`, `poll_number`, `new_marker`, `title`, `lname`, `fname`, `dob`, `flags`, `address` (1–6), `zip`, `date_selected1/2/3`, `rec_num`, `perm_disqual`, `source_id`, `hash_id`.

---

### 6. update watermark

| Attribute | Value |
|-----------|--------|
| **Type** | Copy |
| **Depends on** | Copy to JurorDB (Succeeded) |
| **Timeout** | 12 hours |
| **Retry** | 0 |

**What it does**  
Writes the current run’s completion time to the metadata file so the next run can use it as `lastModified`.

**Source**

- **Dataset**: `DS_Dummy` (e.g. minimal HTTP or in-memory source).
- **Additional column**: `lastExecution` = `@utcNow()`.

**Sink**

- **Dataset**: `DS_metadata_json`  
  - Container: `metadata`  
  - File: `landing.json`  
  - Writes JSON with `lastExecution` (and any other fields from source).

**Result**  
Next pipeline run will read this `landing.json` in **Get metadata files** / **Get Last Modified** and set `lastModified` for incremental processing.

---

## Dependency Summary

| Step | Depends on | Condition |
|------|------------|-----------|
| Set Year Filter | — | — |
| Get metadata files | — | — |
| If file exist | Get metadata files | Succeeded |
| Execute ETL | Set Year Filter, If file exist | Succeeded |
| Copy to JurorDB | Execute ETL | Succeeded |
| update watermark | Copy to JurorDB | Succeeded |

---

## Datasets Referenced

| Dataset | Purpose |
|---------|---------|
| `DS_metadata_json` | Read/write `landing.json` in metadata container (watermark). |
| `DS_Dummy` | Synthetic source for generating watermark JSON in **update watermark**. |
| `DS_Lake_parquet` | Parquet files in processing container (`voters_postgresql/...`). |
| `DS_juror_eric` | PostgreSQL Juror DB target for voter data. |

---

## Notes

- **Incremental load**: Driven by `lastModified` (from `landing.json` or `last_modified` parameter) so only new/changed files are considered.
- **Single run**: `concurrency: 1` avoids overlapping executions.
- **LA-specific**: Source container is fixed to `juror-la-landing` in the ETL call; other parameters allow environment-specific containers and config.
