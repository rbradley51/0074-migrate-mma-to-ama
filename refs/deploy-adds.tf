# https://www.ntweekly.com/2023/04/05/deploy-ad-domain-controller-with-terraform-on-azure/

# This blog post will show you how to deploy a single AD Domain Controller using Terraform.

# Using a single Terraform deployment to deploy an AD domain controller is very handy and a time saver when we need to test something on a sandbox environment quickly.


# The deployment is using a Windows Server 2022 latest build.

# Components
# To get the deployment done, we are using the following five configuration files. The most important one is the AD_Vars file that holds the AD and DC configuration.

# File	Details
# main.tf	Main code
# AD_vars.tf	AD configuration variables
# output.tf	Output file
# provider.tf	Azure provider configuration
# variables.tf	Terraform configuration file
# Deployment files

# Note: The Domain Administrator password is auto-generated using the random module, and you will find it on terraform.tfstate file under the admin_password variable.

# Main.tf

locals { 
  cmd01 = "Install-WindowsFeature AD-Domain-Services -IncludeAllSubFeature -IncludeManagementTools"
  cmd02 = "Install-WindowsFeature DNS -IncludeAllSubFeature -IncludeManagementTools"
  cmd03 = "Import-Module ADDSDeployment, DnsServer"
  cmd04 = "Install-ADDSForest -DomainName ${var.domain_name} -DomainNetbiosName ${var.domain_netbios_name} -DomainMode ${var.domain_mode} -ForestMode ${var.domain_mode} -DatabasePath ${var.database_path} -SysvolPath ${var.sysvol_path} -LogPath ${var.log_path} -NoRebootOnCompletion:$false -Force:$true -SafeModeAdministratorPassword (ConvertTo-SecureString ${var.safe_mode_administrator_password} -AsPlainText -Force)"
  powershell = "${local.cmd01}; ${local.cmd02}; ${local.cmd03}; ${local.cmd04}"

 
}


resource "azurerm_resource_group" "rg" {
name = var.rg_name
location = var.location  
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}



resource "azurerm_network_interface" "winosnic" {
  name                = "${var.winosprefix}-nic"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.winospublicip.id
  }

}

resource "azurerm_network_security_group" "nsg" {
  name                = var.vm_nsg
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

    security_rule {
    name                       = "RDP"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    
  }
}

resource "azurerm_windows_virtual_machine" "winosvm" {
  name                            = "${var.winosprefix}-vm"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  size                            = "Standard_F2s_v2" 
  admin_username                  = "vmadmin"
  admin_password                  = random_password.set_password.result
  network_interface_ids = [
    azurerm_network_interface.winosnic.id,
  ]

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }


}



resource "azurerm_public_ip" "winospublicip" {
  name                = "${var.winosprefix}-pubip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Dynamic"

}

resource "azurerm_network_interface_security_group_association" "securitygroup" {
    network_interface_id      = azurerm_network_interface.winosnic.id
    network_security_group_id = azurerm_network_security_group.nsg.id
}




resource "azurerm_virtual_machine_extension" "software" {
  depends_on=[azurerm_windows_virtual_machine.winosvm]

  name                       = "install-gpmc"
  virtual_machine_id         = azurerm_windows_virtual_machine.winosvm.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.9"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
       "commandToExecute": "powershell.exe -Command \"${local.powershell}\""
 
   }
  SETTINGS
}


resource "random_password" "set_password" {
  length      = 20
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
  min_special = 1
  special     = true
}
AD_Vars.tf

variable "domain_name" {
  type        = string
  default = "ntweekly.com"
}

variable "dc_name" {
  type        = string
  default = "ntdc01"  
}


variable "domain_netbios_name" {
  type        = string
  default = "ntweekly"
}

variable "domain_mode" {
  type        = string
  default     = "WinThreshold" # Windows Server 2016 mode
}

variable "vm_admin_username" {
  type        = string
  default = "vmadmin"
}

variable "domain_admin_password" {
  type        = string
  default = ""
}

variable "database_path" {
  type        = string
  default     = "C:/Windows/NTDS"
}

variable "sysvol_path" {
  type        = string
  default     = "C:/Windows/SYSVOL"
}

variable "log_path" {
  type        = string
  default     = "C:/Windows/NTDS"
}

variable "safe_mode_administrator_password" {
  type        = string
  default = ""  
}
Output.tf
output "public_ip_address" {
  value = azurerm_windows_virtual_machine.winosvm.public_ip_address
}


output "admin_password" {
  sensitive = true
  value     =  azurerm_windows_virtual_machine.winosvm.admin_password
}
Provider.tf
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.47.0"
    }

   random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }



}


provider "azurerm" {
 features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}
Variables.tf
variable "rg_name" {
  type        = string
  default = "Server2022"
  description = "The prefix used for all resources in this example"

}

variable "location" {
  type        = string
  default = "southeastasia"
  description = "The Azure location where all resources in this example should be created"
}


variable "vm_username" {
  type = string
  default = "vmadmin"

}



variable "winosprefix" {
  type = string
  default = "Win2022"
  description = "The prefix which should be used for all resources in this example"
}


variable "vnet_name" {
  type = string
  default = "win_vnet"

}


variable "subnet_name" {
  type = string
  default = "win_vms"

}

variable "nic_name" {
  type = string
  default = "winnic"

}


variable "vm_nsg" {
  type = string
  default = "win_nsg"
}
When deploying, you will be asked to provide the safe_made password, which you can either type or add it as a variable.