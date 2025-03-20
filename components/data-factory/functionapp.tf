resource "azurerm_service_plan" "asp" {
  location            = var.location
  name                = "${var.product}-${var.env}-asp"
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = "B1"
  tags                = module.tags.common_tags
}

resource "azurerm_linux_function_app" "funcapp" {
  name                = "${var.product}-${var.env}-functionapp"
  resource_group_name = var.resource_group_name
  location            = var.location

  storage_account_name       = module.storage.storageaccount_name
  storage_account_access_key = module.storage.storageaccount_primary_access_key
  service_plan_id            = azurerm_service_plan.asp.id

  virtual_network_subnet_id = azurerm_subnet.function_subnet3.id
  site_config {
    application_stack {
      python_version = "~3.12"
    }
  }
  identity {
    type = "SystemAssigned"
  }

  tags = module.tags.common_tags
}
