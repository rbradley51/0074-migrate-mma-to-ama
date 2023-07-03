// backend state file
terraform {
  backend "azurerm" {
      resource_group_name = "tfm-rgp-01"
      storage_account_name = "1sta1739"
      container_name = "tf-tfstate"
      key = "idy.tfstate"
      use_oidc = true
      subscription_id = "e25024e7-c4a5-4883-80af-9e81b2f8f689"
      tenant_id = "440e42a9-54c7-4d77-91a4-306f8fe4183d"
  }
}
