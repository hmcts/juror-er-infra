data "azurerm_key_vault_secret" "postgres_password" {
  name         = "postgrespw"
  key_vault_id = data.azurerm_key_vault.postgres_kv.id
}

data "azurerm_key_vault" "postgres_kv" {
  name                = var.key_vault_name
  resource_group_name = var.resource_group_name
}

data "azurerm_key_vault_secret" "postgres_username" {
  name         = "postgresusername"
  key_vault_id = data.azurerm_key_vault.postgres_kv.id
}

resource "azurerm_postgresql_flexible_server" "adf_juror_postgresql" {
  name                   = "${var.postgresql_server_name}${var.env}"
  resource_group_name    = var.resource_group_name
  location               = var.location
  version                = "15"
  sku_name               = "Standard_D2dsv5"
  storage_mb             = 32768
  administrator_login    = data.azurerm_key_vault_secret.postgres_username.value
  administrator_password = data.azurerm_key_vault_secret.postgres_password.value
  tags                   = module.tags.common_tags
}

