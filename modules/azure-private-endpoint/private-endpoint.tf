resource "azurerm_private_endpoint" "this" {
  name                = var.name
  resource_group_name = var.resource_group
  location            = var.location
  subnet_id           = var.subnet_id
  tags                = var.common_tags

  private_service_connection {
    name                           = var.resource_name
    is_manual_connection           = false
    private_connection_resource_id = var.resource_id
    subresource_names              = [var.subresource_name]
  }

  private_dns_zone_group {
    name                 = "endpoint-dnszonegroup"
    private_dns_zone_ids = [local.subresource_name_dns_zone_map[var.subresource_name]]
  }
}

