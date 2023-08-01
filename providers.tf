terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 3.67.0"
    }
  }
}

# Define the provider configuration

provider "azurerm" {
  use_oidc = true
  features {}
}