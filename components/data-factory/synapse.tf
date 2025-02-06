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
