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
  alias = "hub"
  features {}
  subscription_id = var.hub_subscription_id
}

resource "azurerm_resource_group" "adf_juror_rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = module.tags.common_tags
}
