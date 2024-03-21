terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.96.0"
      configuration_aliases = [
        azurerm.connectivity,
        azurerm.management
      ]
    }
  }
}

provider "azurerm" {
  use_oidc = true
  subscription_id = var.identitySubscriptionId
  features {
    template_deployment {
      delete_nested_items_during_deletion = true
    }
  }
}

provider "azurerm" {
  alias = "connectivity"
  use_oidc = true
  subscription_id = var.connectivitySubscriptionId
  features {
    template_deployment {
      delete_nested_items_during_deletion = true
    }
  }
}

provider "azurerm" {
  alias = "management"
  use_oidc = true
  subscription_id = var.managementSubscriptionId
  features {
    template_deployment {
      delete_nested_items_during_deletion = true
    }
  }
}

module "idy" {
  source = "./modules/plt/idy"

  providers = {
    azurerm = azurerm
    azurerm.connectivity = azurerm.connectivity
    azurerm.management = azurerm.management
  }

  primary_location = var.primary_location
  secondary_location = var.secondary_location
  root_id = var.root_id
  root_name = var.root_name
  identitySubscriptionId = var.identitySubscriptionId
  pw = var.pw
}