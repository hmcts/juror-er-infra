resource "azurerm_storage_account" "adf_juror_sa" {
  name                            = "${var.storage_account_name}${var.env}"
  resource_group_name             = var.resource_group_name
  location                        = var.location
  account_tier                    = var.storage_account_tier
  account_replication_type        = var.storage_account_replication
  account_kind                    = var.storage_account_kind
  allow_nested_items_to_be_public = false
  public_network_access_enabled   = true
  tags                            = module.tags.common_tags
  lifecycle {
    prevent_destroy = false
  }
}

module "storage" {
  source = "github.com/hmcts/cnp-module-storage-account?ref=4.x"

  env                      = var.env
  storage_account_name     = lower(replace("synapse${var.product}${var.env}", "-", ""))
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_kind             = var.storage_account_kind
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_replication
  containers               = var.containers
  enable_versioning        = false
  common_tags              = module.tags.common_tags
}
