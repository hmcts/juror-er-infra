resource "azurerm_storage_account" "adf_jurerstg" {
  name                            = "${var.storage_account_name}${var.env}"
  resource_group_name             = var.resource_group_name
  location                        = var.location
  account_tier                    = var.storage_account_tier
  account_replication_type        = var.storage_account_replication
  account_kind                    = var.storage_account_type
  allow_nested_items_to_be_public = false
  public_network_access_enabled   = false
  tags                            = module.tags.common_tags
  lifecycle {
    prevent_destroy = false
  }
}
