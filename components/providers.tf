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
    resource_group_name  = "azure-control-stg-rg"
    storage_account_name = "c74dacd4faf700dc4cf68sa"
    container_name       = "subscription-tfstate"
    key                  = "UK South/juror-er-infra/terraform.tfstate"
  }
}
