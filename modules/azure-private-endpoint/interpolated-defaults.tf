locals {
  dns_zone_id_prefix = "/subscriptions/1baf5470-1c3e-40d3-a6f7-74bfbce4b348/resourceGroups/core-infra-intsvc-rg/providers/Microsoft.Network/privateDnsZones/"
  subresource_name_dns_zone_map = {
    vault       = "${local.dns_zone_id_prefix}privatelink.vaultcore.azure.net"
    blob        = "${local.dns_zone_id_prefix}privatelink.blob.core.windows.net"
    dfs         = "${local.dns_zone_id_prefix}privatelink.dfs.core.windows.net"
    namespace   = "${local.dns_zone_id_prefix}privatelink.servicebus.windows.net"
    dataFactory = "${local.dns_zone_id_prefix}privatelink.datafactory.azure.net"
    portal      = "${local.dns_zone_id_prefix}privatelink.adf.azure.com"
    sql         = "${local.dns_zone_id_prefix}privatelink.sql.azuresynapse.net"
    sqlOnDemand = "${local.dns_zone_id_prefix}privatelink.sql.azuresynapse.net"
    dev         = "${local.dns_zone_id_prefix}privatelink.dev.azuresynapse.net"
  }
}
