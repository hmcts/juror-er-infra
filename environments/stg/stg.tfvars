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

routes = {
  ss-demo-vnet = {
    address_prefix         = "10.51.64.0/18" # ss-demo-vnet 
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.11.72.36"
  }
}

hub_subscription_id = "fb084706-583f-4c9a-bdab-949aac66ba5c" # HMCTS-HUB-NONPROD-INTSVC
hub_vnet_name       = "hmcts-hub-nonprodi"
