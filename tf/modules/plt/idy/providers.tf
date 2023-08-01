provider "azurerm" {
  use_oidc = true
  subscription_id = var.identitySubscriptionId
  features {}
}