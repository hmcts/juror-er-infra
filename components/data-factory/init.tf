terraform {
  required_version = ">= 1.10.4"

  backend "azurerm" {
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.14.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

provider "azurerm" {
  alias = "HMCTS-HUB-NONPROD-INTSVC"
  features {}
  subscription_id = "fb084706-583f-4c9a-bdab-949aac66ba5c"
}
