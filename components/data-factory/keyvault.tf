data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "baubais_kv" {
  name                     = "${var.product}-${var.env}-kv"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  sku_name                 = "standard"
  tenant_id                = data.azurerm_client_config.current.tenant_id
  purge_protection_enabled = false

  tags = module.tags.common_tags
}

resource "azurerm_key_vault_access_policy" "keyvault_ado_access_policy" {
  key_vault_id   = azurerm_key_vault.baubais_kv.id
  object_id      = data.azurerm_client_config.current.object_id
  tenant_id      = data.azurerm_client_config.current.tenant_id
  application_id = null

  certificate_permissions = []
  key_permissions         = []
  storage_permissions     = []

  secret_permissions = [
        "Get",
        "List",
        "Set",
        "Delete",
        "Purge"
      ]
}

resource "azurerm_key_vault_access_policy" "keyvault_bootstrap_access_policy" {
  key_vault_id   = azurerm_key_vault.baubais_kv.id
  object_id      = var.bootstrap_object_id
  tenant_id      = data.azurerm_client_config.current.tenant_id
  application_id = null

  certificate_permissions = []
  key_permissions         = []
  storage_permissions     = []

  secret_permissions = [
        "Get",
        "List",
        "Set",
        "Delete",
        "Purge"
      ]
}

resource "azurerm_key_vault_access_policy" "keyvault_bootstrap_access_policy" {
  key_vault_id   = azurerm_key_vault.baubais_kv.id
  object_id      = "e7ea2042-4ced-45dd-8ae3-e051c6551789" # DTS Platform Operations
  tenant_id      = data.azurerm_client_config.current.tenant_id
  application_id = null

  certificate_permissions = [
        "Get",
        "List",
        "Update",
        "Create",
        "Import",
        "Delete",
        "Recover",
        "Backup",
        "Restore",
        "ManageContacts",
        "ManageIssuers",
        "GetIssuers",
        "ListIssuers",
        "SetIssuers",
        "DeleteIssuers",
      ]
      key_permissions = [
        "Get",
        "List",
        "Update",
        "Create",
        "Import",
        "Delete",
        "Recover",
        "Backup",
        "Restore",
        "GetRotationPolicy",
        "SetRotationPolicy",
        "Rotate",
      ]
      storage_permissions = []

      secret_permissions = [
        "Get",
        "List",
        "Set",
        "Delete",
        "Purge"
      ]
}
