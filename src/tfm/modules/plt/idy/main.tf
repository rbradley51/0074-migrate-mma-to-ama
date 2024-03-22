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

data "azurerm_management_group" "org" {
  display_name = var.root_name
}

data "azurerm_management_group" "tgt" {
  display_name = var.target_mg_name
}

data "azurerm_resource_group" "iac" {
  name = var.rgpIac
  location = var.primary_location
}

data "azurerm_user_assigned_identity" "umid" {
  name                = var.umi_name
  resource_group_name = azurerm_resource_group.iac.name
}

data "azurerm_monitor_data_collection_rule" "dcr" {
  name                = var.dcr_type.dcr
  resource_group_name = azurerm_resource_group.idy.name
}

data "azurerm_monitor_data_collection_rule" "dcr-ext" {
  name                = var.dcr_type.dcr-ext
  resource_group_name = azurerm_resource_group.idy.name
}

resource "random_uuid" "rnd" {
}

resource "azurerm_resource_group" "idy" {
  name     = var.rgpName
  location = var.primary_location
}

# resource "azurerm_monitor_data_collection_endpoint" "ama_dce" {
#   name                = var.ama_dce.name
#   resource_group_name = azurerm_resource_group.mgt.name
#   location            = var.primary_location

#   lifecycle {
#     create_before_destroy = true
#   }
# }
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

resource "azurerm_management_group_policy_assignment" "ama_initiative_dcr" {
  name                 = var.ama_initiative.name
  policy_definition_id = var.ama_initiative.policy_set_def_id
  management_group_id  = data.azurerm_management_group.tgt.id
  identity {
    type = "SystemAssigned"
  }
  parameters = <<PARAMS
    {
      "enableProcessesAndDependencies": {
        "value": "${var.ama_init_bool.enableProcessesAndDependencies}"
      },
      "bringYourOwnUserAssignedManagedIdentity": {
        "value": "${var.ama_init_bool.bringYourOwnUserAssignedManagedIdentity}"
      },
      "userAssignedManagedIdentityName": {
        "value": "${data.azurerm_user_assigned_identity.umid.name}"
      },
      "userAssignedManagedIdentityResourceGroup": {
        "value": "${data.azurerm_user_assigned_identity.umid.resource_group_name}"
      },
      "scopeToSupportedImages": {
        "value": "${var.ama_init_bool.scopeToSupportedImages}"
      },
      "dcrResourceId": {
        "value": "${var.ama_initiative.dcrResourceId}"
      }
    }
PARAMS
}

resource "azurerm_management_group_policy_assignment" "ama_initiative_dcr_ext" {
  name                 = var.ama_initiative.name
  policy_definition_id = var.ama_initiative.policy_set_def_id
  management_group_id  = data.azurerm_management_group.tgt.id
  identity {
    type = "SystemAssigned"
  }
  parameters = <<PARAMS
    {
      "enableProcessesAndDependencies": {
        "value": "${var.ama_init_bool.enableProcessesAndDependencies}"
      },
      "bringYourOwnUserAssignedManagedIdentity": {
        "value": "${var.ama_init_bool.bringYourOwnUserAssignedManagedIdentity}"
      },
      "userAssignedManagedIdentityName": {
        "value": "${data.azurerm_user_assigned_identity.umid.name}"
      },
      "userAssignedManagedIdentityResourceGroup": {
        "value": "${data.azurerm_user_assigned_identity.umid.resource_group_name}"
      },
      "scopeToSupportedImages": {
        "value": "${var.ama_init_bool.scopeToSupportedImages}"
      },
      "dcrResourceId": {
        "value": "${var.ama_initiative.dcrExtResourceId}"
      }
    }
PARAMS
}
