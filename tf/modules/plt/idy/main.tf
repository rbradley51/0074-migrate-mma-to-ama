provider "azurerm" {
  use_oidc = true
  features {}
}

resource "azurerm_resource_group" "idy" {
  name     = var.rgpName 
  location = var.primary_location
}

resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "West Europe"
}

resource "azurerm_network_security_group" "example" {
  name                = "example-security-group"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_network_security_group" "idy" {
  name                = var.nsgName
  location            = var.primary_location
  resource_group_name = var.rgpName
}
resource "azurerm_virtual_network" "idy" {
  name                = var.vntName
  location            = var.primary_location
  resource_group_name = azurerm_resource_group.idy.name
  address_space       = var.vntAddrSpaces # ["10.0.0.0/16"]
  # dns_servers         = ["10.0.0.4", "10.0.0.5"]

  subnet {
    name           = var.sntName
    address_prefix = var.subAddrPrefixes # ["10.0.1.0/24"]
    security_group = azurerm_network_security_group.idy.id  
}

  tags = {
    environment = "Production"
  }
}

resource "azurerm_network_interface" "ads01" {
  name                = var.ads01NicName 
  location            = var.primary_location
  resource_group_name = var.rgpName

  ip_configuration {
    name                          = var.ads01NicConfigName
    # https://stackoverflow.com/questions/56861532/how-to-reference-objects-in-terraform
    subnet_id                     = azurerm_virtual_network.idy.subnet.*.id[0]
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