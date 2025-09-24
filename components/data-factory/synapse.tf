resource "random_password" "synapse_sql_password" {
  length           = 32
  special          = true
  override_special = "#$%&@()_[]{}<>:?"
  min_upper        = 4
  min_lower        = 4
  min_numeric      = 4
}

resource "azurerm_key_vault_secret" "synapse_sql_password" {
  name         = "${var.product}-synapse-sql-password-${var.env}"
  value        = random_password.synapse_sql_password.result
  key_vault_id = azurerm_key_vault.baubais_kv.id
}

resource "azurerm_key_vault_secret" "synapse_sql_username" {
  name         = "${var.product}-synapse-sql-username-${var.env}"
  value        = "sqladminuser"
  key_vault_id = azurerm_key_vault.baubais_kv.id
}

resource "azurerm_storage_data_lake_gen2_filesystem" "this" {
  name               = "${var.product}-storage-data-lake-${var.env}"
  storage_account_id = module.storage.storageaccount_id
}

resource "azurerm_synapse_workspace" "this" {
  name                                 = "${var.product}-synapse-${var.env}"
  resource_group_name                  = var.resource_group_name
  location                             = var.location
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.this.id
  sql_administrator_login              = "sqladminuser"
  sql_administrator_login_password     = random_password.synapse_sql_password.result
  sql_identity_control_enabled         = true
  data_exfiltration_protection_enabled = false
  managed_virtual_network_enabled      = true
  managed_resource_group_name          = "${var.product}-synapse"

  identity {
    type = "SystemAssigned"
  }

  timeouts {
    create = "2h"
    delete = "2h"
  }

  github_repo {
    account_name    = "hmcts"
    branch_name     = var.github_main_branch
    repository_name = var.github_repository_name
    root_folder     = var.github_root_folder
    git_url         = "https://github.com"
  }
  tags = module.tags.common_tags
}

resource "azurerm_synapse_workspace_aad_admin" "aad" {
  synapse_workspace_id = azurerm_synapse_workspace.this.id
  login                = local.admin_group
  object_id            = data.azuread_group.admin_group.object_id
  tenant_id            = data.azurerm_client_config.current.tenant_id
}
resource "azurerm_synapse_sql_pool" "this" {
  count                = var.enable_synapse_sql_pool ? 1 : 0
  name                 = "${var.product}_synapse_sql_${var.env}"
  synapse_workspace_id = azurerm_synapse_workspace.this.id
  sku_name             = "DW100c"
  create_mode          = "Default"
  storage_account_type = "GRS"

  tags = module.tags.common_tags
}

resource "azurerm_synapse_spark_pool" "this" {
  count                = var.enable_synapse_spark_pool ? 1 : 0
  name                 = "spark${var.env}"
  synapse_workspace_id = azurerm_synapse_workspace.this.id
  node_size_family     = "MemoryOptimized"
  node_size            = "Small"
  cache_size           = 100

  auto_scale {
    max_node_count = 10
    min_node_count = 3
  }

  auto_pause {
    delay_in_minutes = 15
  }

  spark_version = "3.4"
  tags          = module.tags.common_tags
}

locals {
  deploy_pe        = false
  dlrm_admin_group = "DTS DLRM Synapse workspace contributors"
}
module "synapse_pe" {
  for_each = local.deploy_pe ? toset(["sql", "sqlOnDemand", "dev"]) : []
  source   = "../../modules/azure-private-endpoint"

  name             = "${var.product}-synapse-${each.key}-pe-${var.env}"
  resource_group   = var.resource_group_name
  location         = var.location
  subnet_id        = azurerm_subnet.private_endpoints[0].id
  common_tags      = module.tags.common_tags
  resource_name    = azurerm_synapse_workspace.this.name
  resource_id      = azurerm_synapse_workspace.this.id
  subresource_name = each.value
}

resource "azurerm_synapse_firewall_rule" "allowall" {
  name                 = "AllowAll"
  synapse_workspace_id = azurerm_synapse_workspace.this.id
  start_ip_address     = "0.0.0.0"
  end_ip_address       = "255.255.255.255"
}
resource "azurerm_synapse_role_assignment" "this" {
  synapse_workspace_id = azurerm_synapse_workspace.this.id
  role_name            = "Synapse Contributor"
  principal_id         = data.azuread_group.admin_group.object_id # Platops
  depends_on           = [azurerm_synapse_firewall_rule.allowall]
}

data "azuread_group" "dlrm_group" {
  display_name     = local.dlrm_admin_group
  security_enabled = true
}

data "azurerm_storage_account" "bais_bau" {
  name                = "baubais${var.env}"
  resource_group_name = "bau-bais_${var.env}_resource_group"
}


resource "azurerm_synapse_role_assignment" "dlrm" {
  synapse_workspace_id = azurerm_synapse_workspace.this.id
  role_name            = "Synapse Contributor"
  principal_id         = data.azuread_group.dlrm_group.object_id # DTS DLRM Synapse workspace contributors
  depends_on           = [azurerm_synapse_firewall_rule.allowall]
}

resource "azurerm_role_assignment" "baubaiscontributor" {
  principal_id         = azurerm_synapse_workspace.this.identity[0].principal_id
  role_definition_name = "Storage Blob Data Contributor"
  scope                = azurerm_storage_account.adf_juror_sa.id
}

resource "azurerm_role_assignment" "teamcontributor" {
  principal_id         = data.azuread_group.dlrm_group.object_id # DTS DLRM Synapse workspace contributors
  role_definition_name = "Storage Blob Data Contributor"
  scope                = azurerm_storage_account.adf_juror_sa.id
}

resource "azurerm_synapse_role_assignment" "creduser" {
  synapse_workspace_id = azurerm_synapse_workspace.this.id
  role_name            = "Synapse Credential User"
  principal_id         = data.azuread_group.dlrm_group.object_id # DTS DLRM Synapse workspace contributors
  depends_on           = [azurerm_synapse_firewall_rule.allowall]
}

resource "azurerm_role_assignment" "DLRM_sa" {
  principal_id         = data.azuread_group.dlrm_group.object_id # DTS DLRM Synapse workspace contributors
  role_definition_name = "Storage Blob Data Contributor"
  scope                = module.storage.storageaccount_id
}

resource "azurerm_role_assignment" "synapse_sa" {
  principal_id         = azurerm_synapse_workspace.this.identity[0].principal_id
  role_definition_name = "Storage Blob Data Contributor"
  scope                = module.storage.storageaccount_id
}

resource "azurerm_synapse_role_assignment" "anotherone" {
  synapse_workspace_id = azurerm_synapse_workspace.this.id
  role_name            = "Synapse Administrator"
  principal_id         = data.azuread_group.dlrm_group.object_id # DTS DLRM Synapse workspace contributors
  depends_on           = [azurerm_synapse_firewall_rule.allowall]
}


resource "azurerm_role_assignment" "rg_1" {
  principal_id         = data.azuread_group.dlrm_group.object_id # DTS DLRM Synapse workspace contributors
  role_definition_name = "Storage Blob Data Reader"
  scope                = azurerm_resource_group.adf_juror_rg.id
}

resource "azurerm_role_assignment" "rg_2" {
  principal_id         = data.azuread_group.dlrm_group.object_id # DTS DLRM Synapse workspace contributors
  role_definition_name = "Contributor"
  scope                = azurerm_resource_group.adf_juror_rg.id
}
resource "azurerm_role_assignment" "rg_3" {
  principal_id         = data.azuread_group.dlrm_group.object_id # DTS DLRM Synapse workspace contributors
  role_definition_name = "Key Vault Reader"
  scope                = azurerm_resource_group.adf_juror_rg.id
}

resource "azurerm_role_assignment" "bais_bau_reader" {
  scope = azurerm_storage_account.bais_bau.id
  role_definition_name = "Storage File Data Privileged Reader"
  principal_id = azurerm_synapse_workspace.this.identity[0].principal_id
}
