env                   = "stg"
storage_account_name  = "baubaisadfsa"
vnet_name             = "adf-vnet"
vnet_address_space    = ["10.0.2.0/27"]
resource_group_name   = "baubais-data-factory-rg-stg"
subnet1_name          = "adf-privateendpoints"
subnet1_address_space = ["10.0.2.0/28"]
github_configuration = {
  hmcts = {
    account_name       = "hmcts"
    branch_name        = "main"
    git_url            = "https://github.com"
    repository_name    = "juror-er-infra"
    root_folder        = "/adf"
    publishing_enabled = true
  }
}

subscription_id       = "74dacd4f-a248-45bb-a2f0-af700dc4cf68"
subnet2_name          = "synapse-privateendpoints"
subnet2_address_space = ["10.0.2.16/29"]


subnet_function_space = ["10.0.2.24/29"]
