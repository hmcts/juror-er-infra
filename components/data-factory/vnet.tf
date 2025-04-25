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
  delegation {
    name = "function-delegation"
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}


resource "azurerm_virtual_network_peering" "juror-to-hub" {

  name                      = "${azurerm_virtual_network.adf_juror_vnet.name}-to-${var.hub_vnet_name}"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = azurerm_virtual_network.adf_juror_vnet.name
  remote_virtual_network_id = "/subscriptions/${var.hub_subscription_id}/resourceGroups/${var.hub_vnet_name}/providers/Microsoft.Network/virtualNetworks/${var.hub_vnet_name}"

  allow_virtual_network_access = "true"
  allow_forwarded_traffic      = "true"
}

moved {
  from = azurerm_virtual_network_peering.juror-to-hub[0]
  to   = azurerm_virtual_network_peering.juror-to-hub
}
resource "azurerm_virtual_network_peering" "hub-to-juror" {

  provider                  = azurerm.hub
  name                      = "${var.hub_vnet_name}-to-${azurerm_virtual_network.adf_juror_vnet.name}"
  resource_group_name       = var.hub_vnet_name
  virtual_network_name      = var.hub_vnet_name
  remote_virtual_network_id = azurerm_virtual_network.adf_juror_vnet.id

  allow_virtual_network_access = "true"
  allow_forwarded_traffic      = "true"
}

moved {
  from = azurerm_virtual_network_peering.hub-to-juror[0]
  to   = azurerm_virtual_network_peering.hub-to-juror
}
resource "azurerm_route_table" "this" {
  name                = "rt-adf-function-${var.env}"
  location            = var.location
  resource_group_name = var.resource_group_name
  dynamic "route" {
    for_each = var.routes
    content {
      name                   = route.key
      address_prefix         = route.value["address_prefix"]
      next_hop_type          = route.value.next_hop_type
      next_hop_in_ip_address = route.value.next_hop_in_ip_address
    }
  }

  tags = module.tags.common_tags
}

resource "azurerm_subnet_route_table_association" "this" {
  subnet_id      = azurerm_subnet.function_subnet3.id
  route_table_id = azurerm_route_table.this.id
}
