provider "azurerm" {
  features {}
  subscription_id = "74dacd4f-a248-45bb-a2f0-af700dc4cf68"
}

provider "azurerm" {
  features {}
  subscription_id = "74dacd4f-a248-45bb-a2f0-af700dc4cf68"
  alias           = "juror-er"
}


terraform {
  backend "azurerm" {
    resource_group_name  = "rg-juror-er"
    storage_account_name = "stojurorer"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
    subscription_id      = "74dacd4f-a248-45bb-a2f0-af700dc4cf68"
    tenant_id            = "531ff96d-0ae9-462a-8d2d-bec7c0b42082"
  }
}