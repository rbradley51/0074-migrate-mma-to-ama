data "azurerm_virtual_network" "con" {
  provider            = azurerm.connectivity
  name                = var.hub_vnt.name
  resource_group_name = var.hub_vnt.rgp
}

data "azurerm_log_analytics_workspace" "mgt" {
  provider            = azurerm.management
  name                = var.mgt_law.name
  resource_group_name = var.mgt_law.rgp
}

data "azurerm_automation_account" "aaa" {
  provider            = azurerm.management
  name                = var.mgt_aaa.name
  resource_group_name = var.mgt_aaa.rgp
}

data "azurerm_management_group" "org" {
  display_name = var.root_name
}

data "azurerm_resource_group" "iac" {
  name = var.rgpIac
  location = var.primary_location
}

data "azurerm_user_assigned_identity" "umid" {
  name                = var.umi_name
  resource_group_name = azurerm_resource_group.iac.name
}


resource "random_uuid" "rnd" {
}

resource "azurerm_resource_group" "idy" {
  name     = var.rgpName
  location = var.primary_location
}

resource "time_sleep" "wait-for-ads1" {
  depends_on      = [azurerm_virtual_machine_extension.adds]
  create_duration = "120s" # Wait 2 minutes to allow the VM to reboot and stabilize ADDS services
}

resource "azurerm_monitor_data_collection_endpoint" "idy" {
  name                = var.ama_dce.name
  resource_group_name = azurerm_resource_group.idy.name
  location            = var.primary_location

  lifecycle {
    create_before_destroy = true
  }
}

# Create a data collection rule resource
resource "azurerm_monitor_data_collection_rule" "idy" {
  name                        = var.ama_dcr.name
  resource_group_name         = azurerm_resource_group.idy.name
  location                    = var.primary_location
  data_collection_endpoint_id = azurerm_monitor_data_collection_endpoint.idy.id
  destinations {
    log_analytics {
      workspace_resource_id = data.azurerm_log_analytics_workspace.mgt.id
      name                  = data.azurerm_log_analytics_workspace.mgt.name
    }
    azure_monitor_metrics {
      name = var.ama_dcr.destinations.azure_monitor_metrics.name
    }
  }
  data_flow {
    streams      = var.ama_dcr.data_flow.streams
    destinations = [data.azurerm_log_analytics_workspace.mgt.name]
  }
  data_sources {
    performance_counter {
      streams                       = var.ama_dcr.data_sources.performance_counter.streams
      name                          = var.ama_dcr.data_sources.performance_counter.name
      sampling_frequency_in_seconds = var.ama_dcr.data_sources.performance_counter.sampling_frequency_in_seconds
      counter_specifiers            = var.ama_dcr.data_sources.performance_counter.counter_specifiers
    }
    windows_event_log {
      name           = var.ama_dcr.data_sources.windows_event_log.name
      streams        = var.ama_dcr.data_sources.windows_event_log.streams
      x_path_queries = var.ama_dcr.data_sources.windows_event_log.x_path_queries
    }
  }
  identity {
    type         = var.ama_dcr.identity.type
    identity_ids = [azurerm_user_assigned_identity.idy.id]
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/policy_set_definition

resource "azurerm_management_group_policy_assignment" "umi" {
  name                 = var.umi_policy.name
  location             = var.primary_location
  management_group_id  = data.azurerm_management_group.org.id
  policy_definition_id = var.umi_policy.policy_def_id
  identity {
    type = "SystemAssigned"
  }
  parameters = <<PARAMS
    {
      "dcrResourceId": {
        "value": "${azurerm_monitor_data_collection_rule.idy.id}"
      },
      "bringYourOwnUserAssignedManagedIdentity": {
        "value": true
      },
      "userAssignedManagedIdentityName": {
        "value": "${azurerm_user_assigned_identity.idy.name}"
      },
      "userAssignedManagedIdentityResourceGroup": {
        "value": "${azurerm_resource_group.idy.name}"
      },
      "builtInIdentityResourceGroupLocation": {
        "value": "${var.primary_location}"
      }
    }
PARAMS
}

# Add a policy assignment to this resource group scope to assign the user assigned identity to virtual machines
resource "azurerm_management_group_policy_assignment" "umi" {
  name                 = var.umi_policy.name
  location             = var.primary_location
  management_group_id  = data.azurerm_management_group.org.id
  policy_definition_id = var.umi_policy.policy_def_id
  identity {
    type = "SystemAssigned"
  }
  parameters = <<PARAMS
    {
      "dcrResourceId": {
        "value": "${azurerm_monitor_data_collection_rule.idy.id}"
      },
      "bringYourOwnUserAssignedManagedIdentity": {
        "value": true
      },
      "userAssignedManagedIdentityName": {
        "value": "${azurerm_user_assigned_identity.idy.name}"
      },
      "userAssignedManagedIdentityResourceGroup": {
        "value": "${azurerm_resource_group.idy.name}"
      },
      "builtInIdentityResourceGroupLocation": {
        "value": "${var.primary_location}"
      }
    }
PARAMS
}

resource "azurerm_management_group_policy_assignment" "ama_vm" {
  name                 = var.ama_policy.nameVM
  display_name         = "${var.ama_policy.nameVM}-assignment"
  location             = var.primary_location
  management_group_id  = data.azurerm_management_group.org.id
  policy_definition_id = var.ama_policy.vm_policy_def_id

  identity {
    type = "SystemAssigned"
  }
  parameters = <<PARAMS
    {
      "dcrResourceId": {
        "value": "${azurerm_monitor_data_collection_rule.idy.id}"
      },
      "bringYourOwnUserAssignedManagedIdentity": {
        "value": true
      },
      "userAssignedManagedIdentityName": {
        "value": "${azurerm_user_assigned_identity.idy.name}"
      },
      "userAssignedManagedIdentityResourceGroup": {
        "value": "${azurerm_resource_group.idy.name}"
      },
      "enableProcessesAndDependencies": {
        "value": true
      }
    }
PARAMS
}

resource "azurerm_management_group_policy_assignment" "ama_vmss" {
  name                 = var.ama_policy.nameVMSS
  display_name         = "${var.ama_policy.nameVMSS}-assignment"
  location             = var.primary_location
  management_group_id  = data.azurerm_management_group.org.id
  policy_definition_id = var.ama_policy.vmss_policy_def_id
  identity {
    type = "SystemAssigned"
  }
  parameters = <<PARAMS
    {
      "dcrResourceId": {
        "value": "${azurerm_monitor_data_collection_rule.idy.id}"
      },
      "bringYourOwnUserAssignedManagedIdentity": {
        "value": true
      },
      "userAssignedManagedIdentityName": {
        "value": "${azurerm_user_assigned_identity.idy.name}"
      },
      "userAssignedManagedIdentityResourceGroup": {
        "value": "${azurerm_resource_group.idy.name}"
      },
      "enableProcessesAndDependencies": {
        "value": true
      }
    }
PARAMS
}
