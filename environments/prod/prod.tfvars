env                   = "prod"
storage_account_name  = "baubaisadfsa"
vnet_name             = "adf-vnet"
vnet_address_space    = ["10.1.0.0/27"]
resource_group_name   = "baubais-data-factory-rg-prod"
subnet1_name          = "adf-privateendpoints"
subnet1_address_space = ["10.1.2.0/28"]
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

subscription_id       = "5ca62022-6aa2-4cee-aaa7-e7536c8d566c" # DTS-SHAREDSERVICES-PROD
subnet2_name          = "synapse-privateendpoints"
subnet2_address_space = ["10.1.2.16/29"]


subnet_function_space = ["10.1.2.24/29"]

routes = {
  ss-prod-vnet = {
    address_prefix         = "10.144.0.0/18" # ss-prod-vnet 
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.11.8.36" # hmcts-hub-prod-int-palo-lb
  }
}

hub_subscription_id = "0978315c-75fe-4ada-9d11-1eb5e0e0b214" # HMCTS-HUB-PROD-INTSVC
hub_vnet_name       = "hmcts-hub-prod-int"
