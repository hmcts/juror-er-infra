provider "azurerm" {
  features {}
  subscription_id = "04d27a32-7a07-48b3-95b8-3c8691e1a263"
}

provider "azurerm" {
  features {}
  subscription_id = "04d27a32-7a07-48b3-95b8-3c8691e1a263"
  alias           = "juror-er"
}


terraform {
  backend "azurerm" {
    resource_group_name  = "rg-juror-er"
    storage_account_name = "stojurorer"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}
