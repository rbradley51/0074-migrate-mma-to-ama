resource "random_uuid" "rnd" {
}

resource "azurerm_resource_group" "idy" {
  name     = var.rgpName
  location = var.primary_location
}

resource "azurerm_user_assigned_identity" "idy" {
  resource_group_name = azurerm_resource_group.idy.name
  location            = var.primary_location
  name                = "${var.umi_prefix}-${local.rndPrefix}"
}

resource "azurerm_recovery_services_vault" "rsv" {
  name                = "${var.resource_codes.recovery_vault}-${local.rndPrefix}"
  location            = var.primary_location
  resource_group_name = azurerm_resource_group.idy.name
  sku                 = var.rsv_sku
}

resource "azurerm_key_vault" "kvt" {
  name                            = "${var.resource_codes.key_vault}-${local.rndPrefix}"
  location                        = var.primary_location
  resource_group_name             = azurerm_resource_group.idy.name
  sku_name                        = var.kvt_sku
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  purge_protection_enabled        = false
  enabled_for_disk_encryption     = false
  enabled_for_deployment          = true
  enabled_for_template_deployment = true
  soft_delete_retention_days      = var.retention_days
}

resource "azurerm_storage_account" "idy" {
  name                     = "1${var.resource_codes.storage}${local.rndPrefix}"
  location                 = var.primary_location
  account_kind             = var.sta.kind
  account_tier             = var.sta.tier
  account_replication_type = var.sta.replication_type
  resource_group_name      = azurerm_resource_group.idy.name
}
resource "azurerm_storage_container" "ama" {
  name                  = var.sta.container_name
  storage_account_name  = azurerm_storage_account.idy.name
  container_access_type = var.sta.container_access_type
}
resource "azurerm_network_security_group" "idy" {
  count               = length(var.nsg_name)
  name                = var.nsg_name[count.index]
  location            = var.primary_location
  resource_group_name = azurerm_resource_group.idy.name
}

resource "azurerm_network_security_rule" "ads" {
  count                       = length(var.nsg_rules)
  name                        = "ads-${var.nsg_rules[count.index].name}"
  priority                    = var.nsg_rules[count.index].priority
  direction                   = var.nsg_rules[count.index].direction
  access                      = var.nsg_rules[count.index].access
  protocol                    = var.nsg_rules[count.index].protocol
  source_port_range           = var.nsg_rules[count.index].source_port_range
  destination_port_range      = var.nsg_rules[count.index].destination_port_range
  source_address_prefix       = var.nsg_rules[count.index].source_address_prefix
  destination_address_prefix  = var.nsg_rules[count.index].destination_address_prefix
  resource_group_name         = azurerm_resource_group.idy.name
  network_security_group_name = azurerm_network_security_group.idy[0].name
}

resource "azurerm_network_security_rule" "srv" {
  count                       = length(var.nsg_rules)
  name                        = "svr-${var.nsg_rules[count.index].name}"
  priority                    = var.nsg_rules[count.index].priority
  direction                   = var.nsg_rules[count.index].direction
  access                      = var.nsg_rules[count.index].access
  protocol                    = var.nsg_rules[count.index].protocol
  source_port_range           = var.nsg_rules[count.index].source_port_range
  destination_port_range      = var.nsg_rules[count.index].destination_port_range
  source_address_prefix       = var.nsg_rules[count.index].source_address_prefix
  destination_address_prefix  = var.nsg_rules[count.index].destination_address_prefix
  resource_group_name         = azurerm_resource_group.idy.name
  network_security_group_name = azurerm_network_security_group.idy[1].name
}

resource "azurerm_virtual_network" "idy" {
  name                = var.vntName
  location            = var.primary_location
  resource_group_name = azurerm_resource_group.idy.name
  address_space       = var.vntAddressPrefixes
  dns_servers         = ["10.0.0.4","10.0.0.5"]
  subnet {
    name           = var.subnets[0].name
    address_prefix = var.subnets[0].address_prefix
    security_group = azurerm_network_security_group.idy.*.id[0]
  }
  subnet {
    name           = var.subnets[1].name
    address_prefix = var.subnets[1].address_prefix
    security_group = azurerm_network_security_group.idy.*.id[1]
  }
  subnet {
    name           = var.subnets[2].name
    address_prefix = var.subnets[2].address_prefix
  }
}

resource "azurerm_network_interface" "idy" {
  count               = length(var.idy_nics)
  name                = var.idy_nics[count.index].name
  location            = var.primary_location
  resource_group_name = azurerm_resource_group.idy.name
  ip_configuration {
    name      = var.idy_nics[count.index].ipconfig
    subnet_id = (var.idy_nics[count.index].name == "svr01-nic" ? azurerm_virtual_network.idy.subnet.*.id[2] : azurerm_virtual_network.idy.subnet.*.id[0])
    # https://stackoverflow.com/questions/56861532/how-to-reference-objects-in-terraform
    private_ip_address_allocation = var.idy_nics[count.index].prvIpAlloc
    private_ip_address            = var.idy_nics[count.index].prvIpAddr
  }
}

resource "azurerm_public_ip" "bas" {
  count               = local.deploy_bastion ? 1 : 0
  name                = var.bastion.public_ip.name
  location            = var.primary_location
  resource_group_name = azurerm_resource_group.idy.name
  allocation_method   = var.bastion.public_ip.allocation_method
  sku                 = var.bastion.public_ip.sku
}
resource "azurerm_bastion_host" "bas" {
  count               = local.deploy_bastion ? 1 : 0
  name                = var.bastion.name
  location            = var.primary_location
  resource_group_name = azurerm_resource_group.idy.name
  ip_configuration {
    name                 = var.bastion.ipconfig.name
    subnet_id            = azurerm_virtual_network.idy.subnet.*.id[1]
    public_ip_address_id = azurerm_public_ip.bas[0].id
  }
}
resource "azurerm_availability_set" "avs_idy" {
  count                        = length(var.avs_idy)
  name                         = var.avs_idy[count.index].name
  location                     = var.primary_location
  resource_group_name          = azurerm_resource_group.idy.name
  platform_update_domain_count = var.avs_idy[count.index].update_domain
  platform_fault_domain_count  = var.avs_idy[count.index].fault_domain
  managed                      = var.avs_idy[count.index].managed
}

resource "azurerm_virtual_machine" "vms" {
  count                 = length(var.vms)
  name                  = var.vms[count.index].vmName
  location              = var.primary_location
  resource_group_name   = azurerm_resource_group.idy.name
  network_interface_ids = ("${count.index}" == 2 ? azurerm_network_interface.idy[2].*.id : azurerm_network_interface.idy[count.index].*.id)
  vm_size               = var.vms[count.index].vmSize
  availability_set_id   = ("${count.index}" == 1 ? azurerm_availability_set.avs_idy[1].id : azurerm_availability_set.avs_idy[0].id)

  # Uncomment this line to delete the OS disk automatically when deleting the VM.
  delete_os_disk_on_termination = true
  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true
  storage_image_reference {
    publisher = var.vms[count.index].image.publisher
    offer     = var.vms[count.index].image.offer
    sku       = var.vms[count.index].image.sku
    version   = var.vms[count.index].image.version
  }

  storage_os_disk {
    name              = "${var.vms[count.index].vmName}-syst"
    caching           = var.vms[count.index].disk_os.caching
    create_option     = var.vms[count.index].disk_os.createOption
    managed_disk_type = var.vms[count.index].disk_os.diskType
    disk_size_gb      = var.vms[count.index].disk_os.diskSizeGB
  }

  storage_data_disk {
    name              = "${var.vms[count.index].vmName}-data"
    managed_disk_type = var.vms[count.index].disk_data.diskType
    create_option     = var.vms[count.index].disk_data.createOption
    caching           = var.vms[count.index].disk_data.caching
    disk_size_gb      = var.vms[count.index].disk_data.diskSizeGB
    lun               = var.vms[count.index].disk_data.lun
  }
  os_profile {
    computer_name  = var.vms[count.index].vmName
    admin_username = var.vms[count.index].os_profile.admin_username
    admin_password = var.pw
  }
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.idy.id]
  }
  os_profile_windows_config {
    provision_vm_agent        = var.vms[count.index].windows_config.provision_vm_agent
    enable_automatic_upgrades = var.vms[count.index].windows_config.enable_automatic_upgrades
  }
  boot_diagnostics {
    enabled     = var.boot_diag
    storage_uri = azurerm_storage_account.idy.primary_blob_endpoint
  }
  # https://www.terraform.io/docs/providers/azurerm/r/virtual_machine.html
  # https://stackoverflow.com/questions/60265902/terraform-azurerm-virtual-machine-extension-run-local-powershell-script-using-c/60276573#60276573
}

resource "azurerm_virtual_machine_extension" "adds" {
  depends_on=[azurerm_virtual_machine.vms]
  name                       = "install-adds"
  virtual_machine_id         = azurerm_virtual_machine.vms[0].id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.10"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
       "commandToExecute": "powershell.exe -Command \"${local.powershell}\""
 
   }
  SETTINGS
}

resource "azurerm_virtual_machine_extension" "join" {
  depends_on=[azurerm_virtual_machine_extension.adds]
  name                       = "join-server"
  virtual_machine_id         = azurerm_virtual_machine.vms[1].id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.10"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
       "commandToExecute": "powershell.exe -Command \"${local.joinServer}\""
 
   }
  SETTINGS
}

# https://www.vi-tips.com/2020/10/join-vm-to-active-directory-domain-in.html

# task-item: allow network traffic between subnets
# Join svr1 to domain
# https://registry.terraform.io/modules/ghostinthewires/promote-dc/azurerm/latest?tab=inputs


resource "azurerm_automation_account" "aaa" {
  count               = local.deploy_aaa ? 1 : 0
  name                = var.aaa.name
  location            = var.primary_location
  resource_group_name = azurerm_resource_group.idy.name
  sku_name            = var.aaa.sku
}
resource "azurerm_log_analytics_workspace" "law" {
  count               = local.deploy_law ? 1 : 0
  name                = var.law.name
  location            = var.primary_location
  resource_group_name = azurerm_resource_group.idy.name
  sku                 = var.law.sku
  retention_in_days   = var.law.retention_in_days
}
resource "azurerm_log_analytics_linked_service" "aaa_law" {
  count               = local.link_aaa_law ? 1 : 0
  resource_group_name = azurerm_resource_group.idy.name
  workspace_id        = azurerm_log_analytics_workspace.law[0].id
  read_access_id      = azurerm_automation_account.aaa[0].id
}

resource "azurerm_log_analytics_solution" "law" {
  count                 = length(var.law_solutions)
  solution_name         = var.law_solutions[count.index]
  location              = var.primary_location
  resource_group_name   = azurerm_resource_group.idy.name
  workspace_resource_id = azurerm_log_analytics_workspace.law[0].id
  workspace_name        = azurerm_log_analytics_workspace.law[0].name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/${var.law_solutions[count.index]}"
  }
}
resource "azurerm_monitor_data_collection_endpoint" "idy" {
  name                = var.ama_dce.name
  resource_group_name = azurerm_resource_group.idy.name
  location            = var.primary_location

  lifecycle {
    create_before_destroy = true
  }
}

# Create an event hub namespace resource
resource "azurerm_eventhub_namespace" "idy" {
  name                = var.ehb.namespace
  location            = var.primary_location
  resource_group_name = azurerm_resource_group.idy.name
  sku                 = var.ehb.sku
  capacity            = var.ehb.capacity
}

# Create an event hub resource
resource "azurerm_eventhub" "idy" {
  name                = var.ehb.name
  namespace_name      = var.ehb.namespace
  resource_group_name = azurerm_resource_group.idy.name
  partition_count     = var.ehb.partition_count
  message_retention   = var.ehb.message_retention
  depends_on          = [azurerm_eventhub_namespace.idy]
}

# Create a data collection rule resource
resource "azurerm_monitor_data_collection_rule" "idy" {
  name                        = var.ama_dcr.name
  resource_group_name         = azurerm_resource_group.idy.name
  location                    = var.primary_location
  data_collection_endpoint_id = azurerm_monitor_data_collection_endpoint.idy.id
  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.law[0].id
      name                  = azurerm_log_analytics_workspace.law[0].name
    }
    azure_monitor_metrics {
      name = var.ama_dcr.destinations.azure_monitor_metrics.name
    }
  }
  data_flow {
    streams      = var.ama_dcr.data_flow.streams
    destinations = [azurerm_log_analytics_workspace.law[0].name]
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

# Add a policy assignment to this resource group scope to assign the user assigned identity to virtual machines
resource "azurerm_resource_group_policy_assignment" "umi" {
  name                 = var.umi_policy.name
  location             = var.primary_location
  resource_group_id    = azurerm_resource_group.idy.id
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

resource "azurerm_virtual_machine_extension" "idy" {
  count                      = length(var.vms)
  name                       = var.vm_ext.name
  virtual_machine_id         = azurerm_virtual_machine.vms[count.index].id
  publisher                  = var.vm_ext.publisher
  type                       = var.vm_ext.type
  type_handler_version       = var.vm_ext.type_handler_version
  auto_upgrade_minor_version = var.vm_ext.auto_upgrade_minor_version
  automatic_upgrade_enabled  = var.vm_ext.automatic_upgrade_enabled
  settings                   = <<SETTINGS
    {
      "workspaceId": "${azurerm_log_analytics_workspace.law[0].id}"
    }
SETTINGS
}

resource "azurerm_virtual_machine_extension" "nw" {
  count                      = length(var.vms)
  name                       = var.nw_ext.name
  virtual_machine_id         = azurerm_virtual_machine.vms[count.index].id
  publisher                  = var.nw_ext.publisher
  type                       = var.nw_ext.type
  type_handler_version       = var.nw_ext.type_handler_version
  auto_upgrade_minor_version = var.nw_ext.auto_upgrade_minor_version
  automatic_upgrade_enabled  = var.nw_ext.automatic_upgrade_enabled
}

resource "azurerm_resource_group_policy_assignment" "dcra" {
  name                 = var.dcra_policy.name
  location             = var.primary_location
  resource_group_id    = azurerm_resource_group.idy.id
  policy_definition_id = var.dcra_policy.policy_def_id
  identity {
    type = "SystemAssigned"
  }
  parameters = <<PARAMS
    {
      "workspaceResourceId": {
        "value": "${azurerm_log_analytics_workspace.law[0].id}"
      },
      "userGivenDcrName": {
        "value": "${var.dcra_policy.user_given_dcr_name}"
      },
      "enableProcessesAndDependencies": {
        "value": true
      }
    }
PARAMS
}

resource "azurerm_resource_group_policy_assignment" "mde" {
  name                 = var.mde_policy.name
  location             = var.primary_location
  resource_group_id    = azurerm_resource_group.idy.id
  policy_definition_id = var.mde_policy.policy_def_id
  identity {
    type = "SystemAssigned"
  }
  parameters = <<PARAMS
    {
      "microsoftDefenderForEndpointWindowsVmAgentDeployEffect": {
        "value": "${var.mde_policy.microsoftDefenderForEndpointWindowsVmAgentDeployEffect}"
      },
      "microsoftDefenderForEndpointLinuxVmAgentDeployEffect": {
        "value": "${var.mde_policy.microsoftDefenderForEndpointLinuxVmAgentDeployEffect}"
      },
      "microsoftDefenderForEndpointWindowsArcAgentDeployEffect": {
        "value": "${var.mde_policy.microsoftDefenderForEndpointWindowsArcAgentDeployEffect}"
      },
      "microsoftDefenderForEndpointLinuxArcAgentDeployEffect": {
        "value": "${var.mde_policy.microsoftDefenderForEndpointLinuxArcAgentDeployEffect}"
      }
    }
PARAMS
}

# Conectivity checks
data "azurerm_network_watcher" "idy" {
  name                = "NetworkWatcher_${var.primary_location}"
  resource_group_name = "NetworkWatcherRG"
  depends_on = [ azurerm_virtual_network.idy ]
}

# Network watcher
resource "azurerm_network_connection_monitor" "idy" {
  name               = "idy-cmr-${local.rndPrefix}"
  network_watcher_id = data.azurerm_network_watcher.idy.id
  location           = data.azurerm_network_watcher.idy.location

  endpoint {
    name               = azurerm_virtual_machine.vms[0].name
    target_resource_id = azurerm_virtual_machine.vms[0].id

    filter {
      item {
        address = azurerm_virtual_machine.vms[0].id
        type    = "AgentAddress"
      }
      type = "Include"
    }
  }

  endpoint {
    name               = azurerm_virtual_machine.vms[2].name
    target_resource_id = azurerm_virtual_machine.vms[2].id

    filter {
      item {
        address = azurerm_virtual_machine.vms[2].id
        type    = "AgentAddress"
      }
      type = "Include"
    }
  }

  endpoint {
    name    = "dest-global-handler"
    address = "global.handler.control.monitor.azure.com"
  }

  endpoint {
    name    = "dest-regional-handler"
    address = "${var.primary_location}.handler.control.monitor.azure.com"
  }

  endpoint {
    name    = "dest-law-endpoint"
    address = "${azurerm_log_analytics_workspace.law[0].id}.ods.opinsights.azure.com"
  }

  test_configuration {
    name                      = "https"
    protocol                  = "Tcp"
    test_frequency_in_seconds = 30
    tcp_configuration {
      port = 443
    }
  }

  test_group {
    name = "azure_monitor_endpoints_test_group"
    destination_endpoints = [
      "dest-global-handler",
      "dest-regional-handler",
      "dest-law-endpoint"
    ]
    source_endpoints = [
      azurerm_virtual_machine.vms[0].name,
      azurerm_virtual_machine.vms[2].name
    ]
    test_configuration_names = ["https"]
  }

  notes = "NOTE: The 'AzureResourceManager' and 'AzureMonitor' service tag must also be added to the NSG subnet of the source VMs or a firewall."

  output_workspace_resource_ids = [azurerm_log_analytics_workspace.law[0].id]

  depends_on = [azurerm_virtual_machine_extension.nw, azurerm_virtual_machine_extension.adds]
}

# "commandToExecute": "powershell -command \"[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('${base64encode(data.template_file.ADDS.rendered)}')) | Out-File -filepath ADDS.ps1\" && powershell -ExecutionPolicy Unrestricted -File ADDS.ps1 -Domain_DNSName ${data.template_file.ADDS.vars.Domain_DNSName} -Domain_NETBIOSName ${data.template_file.ADDS.vars.Domain_NETBIOSName} -SafeModeAdministratorPassword ${data.template_file.ADDS.vars.SafeModeAdministratorPassword}"
resource "azurerm_virtual_machine_extension" "mde_test_windows" {
  count               = local.test_mde ? 1 : 0
  name                 = azurerm_virtual_machine.vms[2].name
  virtual_machine_id   = azurerm_virtual_machine.vms[2].id 
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"
  auto_upgrade_minor_version = true
  timeouts {
    create = "5m"
    update = "5m"
  }

  settings = <<SETTINGS
 {
  "commandToExecute": "powershell -NoExit -ExecutionPolicy Bypass -WindowsStyle Hidden (New-Object System.Net.WebClient).DownloadFile('http://127.0.0.1/1.exe','C:\\Temp\\invoice.exe'); Start-Process 'C:\\Temp\\invoice.exe'" 
 }
SETTINGS
}