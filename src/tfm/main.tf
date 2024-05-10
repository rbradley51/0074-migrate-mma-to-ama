terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.97.1"
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

provider "azurerm" {
  alias = "iac"
  use_oidc = true
  subscription_id = var.iacSubscriptionId
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
    azurerm.iac = azurerm.iac
  }
  primary_location = var.primary_location
  secondary_location = var.secondary_location
  root_id = var.root_id
  root_name = var.root_name
  target_mg_id = var.target_mg_id
  target_mg_name = var.target_mg_name
  identitySubscriptionId = var.identitySubscriptionId
  managementSubscriptionId = var.managementSubscriptionId
  connectivitySubscriptionId = var.connectivitySubscriptionId
  dceName = var.dceName
  umi_name = var.uami_name
}