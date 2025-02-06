resource "azurerm_virtual_network" "adf_juror_vnet" {
  name                = "${var.vnet_name}-${var.env}"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.vnet_address_space
  tags                = module.tags.common_tags
}

resource "azurerm_subnet" "adf_juror_subnet1" {
  name                 = "${var.subnet1_name}-${var.env}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.adf_juror_vnet.name
  address_prefixes     = var.subnet1_address_space
}