provider "azurerm" {
  use_oidc = true
  features {}
}

resource "azurerm_resource_group" "idy" {
  name     = var.rgpName 
  location = var.primary_location
}

resource "azurerm_virtual_network" "idy" {
  name                = var.vntName 
  address_space       = var.vntAddrSpaces # ["10.0.0.0/16"]
  location            = var.primary_location
  resource_group_name = azurerm_resource_group.idy.name
}

resource "azurerm_network_security_group" "idy" {
  name                = var.nsgName
  location            = var.primary_location
  resource_group_name = var.rgpName
}

resource "azurerm_subnet" "ads" {
  name                 = var.sntName
  resource_group_name  = var.rgpName
  virtual_network_name = azurerm_virtual_network.idy.name
  address_prefixes     = var.subAddrPrefixes # ["10.0.1.0/24"]
  network_security_group_id = azurerm_network_security_group.idy.id
}

resource "azurerm_network_interface" "ads01" {
  name                = var.ads01NicName 
  location            = var.primary_location
  resource_group_name = var.rgpName

  ip_configuration {
    name                          = var.ads01NicConfigName
    subnet_id                     = azurerm_subnet.ads.id
    private_ip_address_allocation = var.prvIpAlloc
  }
}

resource "azurerm_virtual_machine" "ads01" {
  name                  = var.adsO1VmName 
  location            = var.primary_location
  resource_group_name = var.rgpName
  network_interface_ids = [azurerm_network_interface.ads01.id]
  vm_size               = var.vmSize

  storage_image_reference {
    publisher = var.imgPublisher # "MicrosoftWindowsServer"
    offer     = var.imgOffer # "WindowsServer"
    sku       = var.imgSku # "2019-Datacenter"
    version   = var.imgVersion # "latest"
  }

  storage_os_disk {
    name              = var.osDiskName # "syst"
    caching           = var.caching # "ReadWrite"
    create_option     = var.createOption # "FromImage"
    managed_disk_type = var.diskType # "Standard_LRS"
  }

  os_profile {
    computer_name  = var.vmName # "azr-prd-ads-01"
    admin_username = var.userName # "adminuser"
    admin_password = var.pw # "Password1234!"
  }

  os_profile_windows_config {
    provision_vm_agent = var.provisionVmAgent # true
  }
}