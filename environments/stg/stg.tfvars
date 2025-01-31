env                  = "stg"
storage_account_name = "baubaisadfsa"
vnet_name = "baubais-adf-vnet"
vnet_address_space   = ["10.0.2.0/27"]
resource_group_name  = "baubais-data-factory-rg-stg"
subnet1_name         = "baubais-adf-privateendpoints"
subnet1_address_space = ["10.0.2.0/28"]
github_configuration = {
  hmcts_config = {
    account_name       = "hmcts"
    branch_name        = "main"
    git_url            = "https://github.com"
    repository_name    = "juror-er-infra"
    root_folder        = "/adf"
    publishing_enabled = true
  }
}