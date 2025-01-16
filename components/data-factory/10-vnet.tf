resource "azurerm_virtual_network" "adf_juror_vnet" {
  name                = "${var.storage_account_name}${var.env}"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.vnet_address_space
  tags                = module.tags.common_tags
}