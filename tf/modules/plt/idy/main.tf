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
  security_rule {
    name                       = var.nsg_name[count.index]
    priority                   = var.nsg_rule_sets[count.index].priority
    direction                  = var.nsg_rule_sets[count.index].direction
    access                     = var.nsg_rule_sets[count.index].access
    protocol                   = var.nsg_rule_sets[count.index].protocol
    source_port_range          = var.nsg_rule_sets[count.index].source_port_range
    destination_port_range     = var.nsg_rule_sets[count.index].destination_port_range
    source_address_prefix      = var.nsg_rule_sets[count.index].source_address_prefix
    destination_address_prefix = var.nsg_rule_sets[count.index].destination_address_prefix
  }
}

resource "azurerm_virtual_network" "idy" {
  name                = var.vntName
  location            = var.primary_location
  resource_group_name = azurerm_resource_group.idy.name
  address_space       = var.vntAddressPrefixes
  dns_servers         = var.dns_servers
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
    name = var.idy_nics[count.index].ipconfig
    subnet_id = (var.idy_nics[count.index].name == "svr01-nic" ? azurerm_virtual_network.idy.subnet.*.id[2] : azurerm_virtual_network.idy.subnet.*.id[0])
    # https://stackoverflow.com/questions/56861532/how-to-reference-objects-in-terraform
    private_ip_address_allocation = var.idy_nics[count.index].prvIpAlloc
    private_ip_address            = var.idy_nics[count.index].prvIpAddr
  }
}

resource "azurerm_public_ip" "bas" {
  count = local.deploy_bastion ? 1 : 0
  name                = var.bastion.public_ip.name
  location            = var.primary_location
  resource_group_name = azurerm_resource_group.idy.name
  allocation_method   = var.bastion.public_ip.allocation_method
  sku                 = var.bastion.public_ip.sku
}
resource "azurerm_bastion_host" "bas" {
  count = local.deploy_bastion ? 1 : 0
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

  # Uncomment this line to delete the OS disk automatically when deleting the VM
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
    type = "UserAssigned"
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
}

resource "azurerm_automation_account" "aaa" {
  count = local.deploy_aaa ? 1 : 0
  name                = var.aaa.name
  location            = var.primary_location
  resource_group_name = azurerm_resource_group.idy.name
  sku_name            = var.aaa.sku
}
resource "azurerm_log_analytics_workspace" "law" {
  count = local.deploy_law ? 1 : 0
  name                = var.law.name
  location            = var.primary_location
  resource_group_name = azurerm_resource_group.idy.name
  sku                 = var.law.sku
  retention_in_days   = var.law.retention_in_days
}
resource "azurerm_log_analytics_linked_service" "aaa_law" {
  count = local.link_aaa_law ? 1 : 0
  resource_group_name = azurerm_resource_group.idy.name
  workspace_id        = azurerm_log_analytics_workspace.law[0].id
  read_access_id      = azurerm_automation_account.aaa[0].id
}

resource "azurerm_log_analytics_solution" "law" {
  count = length(var.law_solutions)
  solution_name       = var.law_solutions[count.index]
  location            = var.primary_location
  resource_group_name = azurerm_resource_group.idy.name
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
    create_before_destroy = var.ama_dce.create_before_destroy
  }
}