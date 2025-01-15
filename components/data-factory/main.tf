module "datafactory" {
  source = "git::https://github.com/hmcts/terraform-module-azure-datafactory.git?ref=main"
  env    = var.env

  product   = "baubais"
  component = "data-factory"

  common_tags = module.tags.common_tags
}

module "tags" {
  source = "github.com/hmcts/terraform-module-common-tags?ref=master"

  builtFrom   = "hmcts/terraform-module-mssql"
  environment = var.env
  product     = "sds-platform"
}

resource "azurerm_storage_account" "adf_jurerstg_" {
  name                            = var.storage_account_name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  account_tier                    = var.storage_account_tier
  account_replication_type        = var.storage_account_replication
  account_kind                    = var.storage_account_type
  allow_nested_items_to_be_public = false
  public_network_access_enabled   = false
  tags                            = module.ctags.common_tags
  lifecycle {
    prevent_destroy = false
  }
}
