module "datafactory" {
  source = "https://github.com/hmcts/terraform-module-azure-datafactory?ref=main"
  env    = var.env

  product   = "baubais"
  component = "datafactory"

  common_tags = module.common_tags.common_tags
}

module "common_tags" {
  source = "github.com/hmcts/terraform-module-common-tags?ref=master"

  builtFrom   = "hmcts/terraform-module-mssql"
  environment = var.env
  product     = "sds-platform"
}
