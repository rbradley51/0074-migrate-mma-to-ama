terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">=3.97.1"
      configuration_aliases = [
        azurerm.connectivity,
        azurerm.management,
        azurerm.iac
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