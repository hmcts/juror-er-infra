# Juror ER (Eric) — Data flow diagram

This document contains Mermaid diagrams for the **p_Ingestion_Controller_la** and **p_er_juror_eric_etl** pipelines. Render in any Markdown viewer that supports Mermaid (e.g. GitHub, Azure DevOps, VS Code with Mermaid extension).

---

## Gliffy format

A **Gliffy-native diagram** is provided for use in Gliffy (Confluence, Jira, Gliffy Online) or in draw.io (File → Import from → Device):

| File | Description |
|------|--------------|
| **[juror-er-data-flow.gliffy](juror-er-data-flow.gliffy)** | Data flow: Sources → ETL (L0–L3) → processing_container → Sinks. Left-to-right layout with labeled shapes. Open in Gliffy or import into draw.io; add connectors between shapes as needed. |

---

## 1. End-to-end data flow (ETL + controller)

Shows how data moves from source containers through the four ETL stages to Delta, PostgreSQL, and Power BI.

```mermaid
flowchart TB
    subgraph SOURCES["Sources"]
        BAIS["BAIS / source_container<br/>(CSV, Excel, ZIP)"]
        CONFIG["config_container<br/>config/schema & config/rules"]
        META_IN["metadata container<br/>landing.json (watermark)"]
    end

    subgraph CONTROLLER["p_Ingestion_Controller_la"]
        SET_YEAR["Set Year Filter"]
        GET_META["Get metadata files"]
        IF_FILE["If file exist"]
        EXEC_ETL["Execute ETL<br/>p_er_juror_eric_etl"]
        COPY_DB["Copy to JurorDB"]
        UPDATE_WM["update watermark"]
    end

    subgraph ETL["p_er_juror_eric_etl"]
        L0["L0_Data_Ingestion<br/>L0_Er_Juror_Ingestion"]
        L1["L1_MappingSchema<br/>L1_Er_Juror_MappingSchema"]
        L2["L2_MergingFiles<br/>L2_Er_Juror_Mergingfiles"]
        L3["L3_DataLake_ErickSchema<br/>L3_Er_Juror_DataLake_ErickSchema"]
    end

    subgraph PROCESSING["processing_container"]
        FILES["files/<br/>Parquet"]
        TRANSFORM["transformation/<br/>Parquet"]
        VOTERS_TF["voters_transformed/<br/>Delta"]
        VOTERS_PG["voters_postgresql/<br/>Parquet partitioned"]
        QUARANTINE["quarantine/, metadata/,<br/>empty/, overseas/"]
        LOGS["L0/L1/L2 process logs"]
    end

    subgraph SINKS["Sinks"]
        DELTA["eric_voters_tmp_container<br/>voters_deduplicated_delta (Delta)"]
        POWERBI["dl-juror-eric-power-bi<br/>er_juror_report (Delta)"]
        JUROR_DB[("Juror DB<br/>PostgreSQL")]
        META_OUT["metadata container<br/>landing.json"]
    end

    META_IN --> GET_META
    GET_META --> IF_FILE
    SET_YEAR --> IF_FILE
    IF_FILE --> EXEC_ETL
    BAIS --> L0
    L0 --> FILES
    L0 --> QUARANTINE
    L0 --> LOGS
    CONFIG --> L1
    FILES --> L1
    L1 --> TRANSFORM
    L1 --> LOGS
    CONFIG --> L2
    TRANSFORM --> L2
    L2 --> VOTERS_TF
    L2 --> VOTERS_PG
    L2 --> LOGS
    VOTERS_PG --> L3
    L3 --> DELTA
    L3 --> POWERBI
    EXEC_ETL --> L0
    VOTERS_PG --> COPY_DB
    COPY_DB --> JUROR_DB
    COPY_DB --> UPDATE_WM
    UPDATE_WM --> META_OUT
```

---

## 2. ETL pipeline only (data stores and notebooks)

Simplified view: data stores and the four notebooks in sequence.

```mermaid
flowchart LR
    subgraph IN["Inputs"]
        SRC["source_container<br/>CSV, Excel, ZIP"]
        CFG["config_container<br/>schema & rules"]
    end

    SRC -->|"raw files"| L0
    L0 -->|"Parquet"| FILES[("files/")]
    FILES --> L1
    CFG --> L1
    L1 -->|"Parquet"| TRANS[("transformation/")]
    TRANS --> L2
    CFG --> L2
    L2 -->|"Delta"| VTF[("voters_transformed/")]
    L2 -->|"Parquet"| VPG[("voters_postgresql/")]
    VPG --> L3
    L3 -->|"Delta CDC"| DELTA[("voters_deduplicated_delta")]
    L3 -->|"Delta agg"| PBI[("er_juror_report")]

    subgraph NOTEBOOKS["Notebooks"]
        L0["L0 Ingestion"]
        L1["L1 MappingSchema"]
        L2["L2 MergingFiles"]
        L3["L3 DataLake ErickSchema"]
    end
```

---

## 3. Controller pipeline (activity flow)

Orchestration steps and how they connect to the ETL and Copy to JurorDB.

```mermaid
flowchart TB
    subgraph PREP["Preparation"]
        A["Set Year Filter"]
        B["Get metadata files"]
        C{"If file exist"}
        D["Set default time<br/>lastModified = param or 1900-01-01"]
        E["Get Last Modified"]
        F["Set last modified<br/>lastModified = landing.json"]
    end

    subgraph RUN["Run & load"]
        G["Execute ETL<br/>p_er_juror_eric_etl"]
        H["Copy to JurorDB<br/>Parquet → PostgreSQL"]
        I["update watermark<br/>write landing.json"]
    end

    A --> C
    B --> C
    C -->|false| D
    C -->|true| E
    E --> F
    D --> G
    F --> G
    G --> H
    H --> I
```

---

## 4. Container and path reference

| Symbol / path | Container | Description |
|---------------|-----------|-------------|
| source_container | (param) | Raw BAIS files (e.g. juror-la-landing). |
| processing_container | (param) | All intermediate and output paths below. |
| config_container | (param) | Column mapping and validation rules. |
| files/ | processing_container | L0 output Parquet. |
| transformation/ | processing_container | L1 output Parquet. |
| voters_transformed/ | processing_container | L2 Delta table. |
| voters_postgresql/ | processing_container | L2 Parquet for Copy to JurorDB. |
| voters_deduplicated_delta | eric_voters_tmp_container | L3 Delta (CDC). |
| er_juror_report | dl-juror-eric-power-bi | L3 aggregated Delta for Power BI. |
| metadata / landing.json | metadata | Watermark for incremental runs. |
