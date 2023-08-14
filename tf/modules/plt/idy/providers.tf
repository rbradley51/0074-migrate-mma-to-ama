provider "azurerm" {
  use_oidc = true
  subscription_id = var.identitySubscriptionId
  features {
    purge_soft_delete_on_destroy = true
  }
}