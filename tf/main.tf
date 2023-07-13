# Configure Terraform to set the required AzureRM provider
# version and features{} block

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 3.7.0"
    }
  }
}

# Define the provider configuration

provider "azurerm" {
  use_oidc = true
  features {}
}

# Get the current client configuration from the AzureRM provider

data "azurerm_client_config" "current" {}

module "idy" {
  source = "./modules/plt/idy"
  primary_location = var.primary_location
  secondary_location = var.secondary_location
  root_id = var.root_id
  root_name = var.root_name
  identitySubscriptionId = var.identitySubscriptionId
  pw = var.pw
}