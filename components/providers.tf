provider "azurerm" {
  features {}
  subscription_id = "74dacd4f-a248-45bb-a2f0-af700dc4cf68"
}

provider "azurerm" {
  features {}
  subscription_id = "74dacd4f-a248-45bb-a2f0-af700dc4cf68"
  alias           = "juror-er-stg"
}


terraform {
  backend "azurerm" {
    resource_group_name  = "azure-control-stg-rg"
    storage_account_name = "c74dacd4faf700dc4cf68sa"
    container_name       = "subscription-tfstate"
    key                  = "UK South/juror-er-infra/terraform.tfstate"
    subscription_id      = "04d27a32-7a07-48b3-95b8-3c8691e1a263"
  }
}
