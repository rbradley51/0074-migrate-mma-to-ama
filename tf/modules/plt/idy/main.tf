resource "random_uuid" "rnd" {
}

resource "azurerm_resource_group" "idy" {
  name     = var.rgpName
  location = var.primary_location
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

resource "azurerm_network_security_group" "idy" {
  count = length(var.nsg_name)
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
    name = var.subnets[0].name
    address_prefix = var.subnets[0].address_prefix
    security_group = azurerm_network_security_group.idy.*.id[0]
  }
  subnet {
    name = var.subnets[1].name
    address_prefix = var.subnets[1].address_prefix
    security_group = azurerm_network_security_group.idy.*.id[1]
  }
}

resource "azurerm_network_interface" "ads" {
  count = length(var.ads_nics)
  name = var.ads_nics[count.index].name
  location           = var.primary_location
  resource_group_name = azurerm_resource_group.idy.name
  ip_configuration {
    name                          = var.ads_nics[count.index].ipconfig
    subnet_id           = azurerm_virtual_network.idy.subnet.*.id[0]
    # https://stackoverflow.com/questions/56861532/how-to-reference-objects-in-terraform
    private_ip_address_allocation = var.ads_nics[count.index].prvIpAlloc
    private_ip_address            = var.ads_nics[count.index].prvIpAddr
  }
}
resource "azurerm_network_interface" "svr" {
  name = var.srv_nics.name
  location           = var.primary_location
  resource_group_name = azurerm_resource_group.idy.name
  ip_configuration {
    name                         = var.srv_nics.ipconfig
    subnet_id           = azurerm_virtual_network.idy.subnet.*.id[1]
    private_ip_address_allocation = var.srv_nics.prvIpAlloc
    private_ip_address            = var.srv_nics.prvIpAddr
  }
}
resource "azurerm_availability_set" "avs_idy" {
  count = length(var.avs_idy)
  name  = var.avs_idy[count.index].name
  location            = var.primary_location
  resource_group_name = azurerm_resource_group.idy.name
  platform_update_domain_count = var.avs_idy[count.index].update_domain
  platform_fault_domain_count = var.avs_idy[count.index].fault_domain
  managed = var.avs_idy[count.index].managed
}

# resource "azurerm_virtual_machine" "ads01" {
#   name                  = var.idy.settings.identity.config.vm.vmName
#   location            = var.idy.settings.identity.config.primary_location
#   resource_group_name = var.idy.settings.identity.config.rgpName
#   network_interface_ids = [azurerm_network_interface.ads01.id]
#   vm_size               = var.idy.settings.identity.config.vm.vmSize
#   availability_set_id   = azurerm_availability_set.avs01.id

#   storage_image_reference {
#     publisher = var.idy.settings.identity.config.vm.vmName 
#     offer     = var.idy.settings.identity.config.image.publisher 
#     sku       = var.idy.settings.identity.config.image.sku 
#     version   = var.idy.settings.identity.config.image.version
#   }

#   storage_os_disk {
#     name              = var.idy.settings.identity.config.disk.osDiskName
#     caching           = var.idy.settings.identity.config.disk.caching
#     create_option     = var.idy.settings.identity.config.disk.createOption
#     managed_disk_type = var.idy.settings.identity.config.disk.diskType
#   }

#   os_profile {
#     computer_name  = var.idy.settings.identity.config.vm.vmName
#     admin_username = var.idy.settings.identity.config.vm.userName
#     admin_password = var.vm.pw
#   }

#   os_profile_windows_config {
#     provision_vm_agent = var.idy.settings.identity.config.vm.provisionVmAgent
#   }
# }
