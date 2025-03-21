module "datafactory" {
  source               = "git::https://github.com/hmcts/terraform-module-azure-datafactory.git?ref=main"
  env                  = var.env
  github_configuration = var.github_configuration

  product   = var.product
  component = "data-factory"

  common_tags = module.tags.common_tags
}

module "tags" {
  source = "github.com/hmcts/terraform-module-common-tags?ref=master"

  builtFrom   = "hmcts/juror-er-infra"
  environment = var.env
  product     = var.product
}
