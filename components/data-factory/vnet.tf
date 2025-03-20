resource "azurerm_virtual_network" "adf_juror_vnet" {
  name                = "${var.product}-${var.vnet_name}-${var.env}"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.vnet_address_space
  tags                = module.tags.common_tags
}

resource "azurerm_subnet" "adf_juror_subnet1" {
  name                 = "${var.product}-${var.subnet1_name}-${var.env}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.adf_juror_vnet.name
  address_prefixes     = var.subnet1_address_space
}

resource "azurerm_subnet" "private_endpoints" {
  count                = local.deploy_pe ? 1 : 0
  name                 = "${var.product}-${var.subnet2_name}-${var.env}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.adf_juror_vnet.name
  address_prefixes     = var.subnet2_address_space
}
resource "azurerm_subnet" "function_subnet3" {
  name                 = var.subnet_fuction_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.adf_juror_vnet.name
  address_prefixes     = var.subnet_function_space
}


resource "azurerm_virtual_network_peering" "juror-to-hub" {
  name                      = "${azurerm_virtual_network.adf_juror_vnet.name}-to-hmcts-hub-nonprodi"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = azurerm_virtual_network.adf_juror_vnet.name
  remote_virtual_network_id = "/subscriptions/fb084706-583f-4c9a-bdab-949aac66ba5c/resourceGroups/hmcts-hub-nonprodi/providers/Microsoft.Network/virtualNetworks/hmcts-hub-nonprodi"

  allow_virtual_network_access = "true"
  allow_forwarded_traffic      = "true"
}

resource "azurerm_virtual_network_peering" "hub-to-juror" {

  provider                  = azurerm.HMCTS-HUB-NONPROD-INTSVC
  name                      = "hmcts-hub-nonprodi-to-${azurerm_virtual_network.adf_juror_vnet.name}"
  resource_group_name       = "hmcts-hub-nonprodi"
  virtual_network_name      = "hmcts-hub-nonprodi"
  remote_virtual_network_id = azurerm_virtual_network.adf_juror_vnet.id

  allow_virtual_network_access = "true"
  allow_forwarded_traffic      = "true"
}
