terraform {
  required_providers {
    # Update the AzureRM Provider to version 3.89.0
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 3.89.0"
    }
  }
}

# Define the provider configuration

provider "azurerm" {
  use_oidc = true
  features {}
}