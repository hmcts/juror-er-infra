terraform {
  required_version = ">= 1.0.10"

  backend "azurerm" {
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.10.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azurerm" {
  features {}
  subscription_id = "74dacd4f-a248-45bb-a2f0-af700dc4cf68"
  alias           = "juror-er-stg"
}