module "datafactory" {
  source = "git::https://github.com/hmcts/terraform-module-azure-datafactory.git?ref=main"
  env    = var.env

  product   = "baubais"
  component = "datafactory"

  common_tags = module.tags.common_tags
}

module "tags" {
  source = "github.com/hmcts/terraform-module-common-tags?ref=master"

  builtFrom   = "hmcts/terraform-module-mssql"
  environment = var.env
  product     = "sds-platform"
}


resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = module.tags.common_tags
}

