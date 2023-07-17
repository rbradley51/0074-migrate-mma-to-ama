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
  sku = var.rsv_sku
}

resource "azurerm_key_vault" "kvt" {
  name = "${var.resource_codes.key_vault}-${local.rndPrefix}"
  location = var.primary_location
  resource_group_name = azurerm_resource_group.idy.name
  sku_name = var.kvt_sku
  tenant_id = data.azurerm_client_config.current.tenant_id
  purge_protection_enabled = false
  enabled_for_disk_encryption = false
  enabled_for_deployment = true
  enabled_for_template_deployment = true
  soft_delete_retention_days = var.retention_days
}

# resource "azurerm_storage_account" "idy" {
#   account_kind = "StorageV2"
#   account_tier = "Standard"
#   account_replication_type = "LRS"
#   resource_group_name = var.idy.settings.identity.config.rgpName

# }

# resource "azurerm_network_security_group" "idy" {
#   name                = var.idy.settings.identity.config.vnet.subnet.nsgName
#   location            = var.idy.settings.identity.config.primary_location
#   resource_group_name = var.idy.settings.identity.config.rgpName
# }
# resource "azurerm_virtual_network" "idy" {
#   name                = var.idy.settings.identity.config.vnet.vntName
#   location            = var.idy.settings.identity.config.primary_location
#   resource_group_name = var.idy.settings.identity.config.rgpName
#   address_space       = var.idy.settings.identity.config.vnet.vntAddrSpaces # ["10.0.0.0/28"]
#   # dns_servers         = ["10.0.0.4", "10.0.0.5"]

#   subnet {
#     name           = var.idy.settings.identity.config.vnet.subnet.sntName
#     address_prefix = var.idy.settings.identity.config.vnet.subnet.subAddrPrefix # ["10.0.0.0/29"]
#     security_group = azurerm_network_security_group.idy.id  
# }

#   tags = {
#     var.idy.settings.identity.config.tags.environment.key = var.idy.settings.identity.config.tags.environment.value
#   }
# }

# resource "azurerm_network_interface" "ads01" {
#   name                = var.idy.settings.identity.config.vnet.subnet.nic.ads01NicName
#   location            = var.idy.settings.identity.config.primary_location
#   resource_group_name = var.idy.settings.identity.config.rgpName

#   ip_configuration {
#     name                          = var.idy.settings.identity.config.vnet.subnet.nic.ads01NicConfigName
#     # https://stackoverflow.com/questions/56861532/how-to-reference-objects-in-terraform
#     subnet_id                     = azurerm_virtual_network.idy.subnet.*.id[0]
#     private_ip_address_allocation = var.idy.settings.identity.config.vnet.subnet.nic.prvIpAlloc
#   }
# }

# resource "azurerm_availability_set" "avs01" {
#   name                = var.idy.settings.identity.config.avset.avsetName
#   location            = var.idy.settings.identity.config.primary_location
#   resource_group_name = var.idy.settings.identity.config.rgpName
# }
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