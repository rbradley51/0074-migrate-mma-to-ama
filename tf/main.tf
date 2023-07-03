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
  subscription_id = "${var.subscription_id_identity}"
  tenant_id       = "${var.tenant_id}"
  client_id       = "${var.client_id}"
  features {}
}

# Get the current client configuration from the AzureRM provider

data "azurerm_client_config" "current" {}

module "idy" {
  source = "./modules/plt/idy"
}
