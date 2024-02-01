provider "azurerm" {
  use_oidc = true
  subscription_id = var.identitySubscriptionId
  features {
    template_deployment {
      delete_nested_items_during_deletion = true
    }
  }
}