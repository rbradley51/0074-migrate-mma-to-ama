# Get the current client configuration from the AzureRM provider

module "idy" {
  source = "./modules/plt/idy"
  primary_location = var.primary_location
  secondary_location = var.secondary_location
  root_id = var.root_id
  root_name = var.root_name
  identitySubscriptionId = var.identitySubscriptionId
  # pw = var.pw
}