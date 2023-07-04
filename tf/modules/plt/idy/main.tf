provider "azurerm" {
  use_oidc = true
  features {}
}

resource "random_uuid" "rnd" {
}

idy = local.configure_identity_resources
resource "azurerm_recovery_services_vault" "rsv" {
  name                = "rsv-${random_uuid.rnd.result}"
  location            = idy.settings.identity.config.primary_location
  resource_group_name = idy.settings.identity.config.rgpName
}

resource "azurerm_key_vault" "kvt" {
  name = "kvt-${random_uuid.rnd.result}"
  location = idy.settings.identity.config.primary_location
  resource_group_name = idy.settings.identity.config.rgpName
  sku_name = idy.settings.identity.config.kvt.sku
  tenant_id = idy.settings.identity.config.tenant_id
  soft_delete_enabled = true
  purge_protection_enabled = false
  enabled_for_disk_encryption = false
  enabled_for_deployment = true
  enabled_for_template_deployment = true
  enabled_for_volume_encryption = false
}

resource "azurerm_resource_group" "idy" {
  name     = idy.settings.identity.config.rgpName 
  location = idy.settings.identity.config.primary_location
}

resource "azurerm_storage_account" "idy" {
  account_kind = "StorageV2"
  account_tier = "Standard"
  account_replication_type = "LRS"
  resource_group_name = idy.settings.identity.config.rgpName

}

resource "azurerm_network_security_group" "idy" {
  name                = idy.settings.identity.config.vnet.subnet.nsgName
  location            = idy.settings.identity.config.primary_location
  resource_group_name = idy.settings.identity.config.rgpName
}
resource "azurerm_virtual_network" "idy" {
  name                = idy.settings.identity.config.vnet.vntName
  location            = idy.settings.identity.config.primary_location
  resource_group_name = idy.settings.identity.config.rgpName
  address_space       = idy.settings.identity.config.vnet.vntAddrSpaces # ["10.0.0.0/28"]
  # dns_servers         = ["10.0.0.4", "10.0.0.5"]

  subnet {
    name           = idy.settings.identity.config.vnet.subnet.sntName
    address_prefix = idy.settings.identity.config.vnet.subnet.subAddrPrefix # ["10.0.0.0/29"]
    security_group = azurerm_network_security_group.idy.id  
}

  tags = {
    idy.settings.identity.config.tags.environment.key = idy.settings.identity.config.tags.environment.value
  }
}

resource "azurerm_network_interface" "ads01" {
  name                = idy.settings.identity.config.vnet.subnet.nic.ads01NicName
  location            = idy.settings.identity.config.primary_location
  resource_group_name = idy.settings.identity.config.rgpName

  ip_configuration {
    name                          = idy.settings.identity.config.vnet.subnet.nic.ads01NicConfigName
    # https://stackoverflow.com/questions/56861532/how-to-reference-objects-in-terraform
    subnet_id                     = azurerm_virtual_network.idy.subnet.*.id[0]
    private_ip_address_allocation = idy.settings.identity.config.vnet.subnet.nic.prvIpAlloc
  }
}

resource "azurerm_availability_set" "avs01" {
  name                = idy.settings.identity.config.avset.avsetName
  location            = idy.settings.identity.config.primary_location
  resource_group_name = idy.settings.identity.config.rgpName
}
resource "azurerm_virtual_machine" "ads01" {
  name                  = idy.settings.identity.config.vm.vmName
  location            = idy.settings.identity.config.primary_location
  resource_group_name = idy.settings.identity.config.rgpName
  network_interface_ids = [azurerm_network_interface.ads01.id]
  vm_size               = idy.settings.identity.config.vm.vmSize
  availability_set_id   = azurerm_availability_set.avs01.id

  storage_image_reference {
    publisher = idy.settings.identity.config.vm.vmName 
    offer     = idy.settings.identity.config.image.publisher 
    sku       = idy.settings.identity.config.image.sku 
    version   = idy.settings.identity.config.image.version
  }

  storage_os_disk {
    name              = idy.settings.identity.config.disk.osDiskName
    caching           = idy.settings.identity.config.disk.caching
    create_option     = idy.settings.identity.config.disk.createOption
    managed_disk_type = idy.settings.identity.config.disk.diskType
  }

  os_profile {
    computer_name  = idy.settings.identity.config.vm.vmName
    admin_username = idy.settings.identity.config.vm.userName
    admin_password = var.pw
  }

  os_profile_windows_config {
    provision_vm_agent = idy.settings.identity.config.vm.provisionVmAgent
  }
}