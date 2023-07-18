variable "rgpName" {
  type        = string
  description = "values for resource group name"
  default     = "rgp-ads"
}

variable "nic" {
  type        = map(string)
  description = "values for network interface"
  default = {
    name       = "ads01-nic"
    prvIpAlloc = "Dynamic"
  }
}

variable "kvt_sku" {
  type        = string
  description = "values for key vault sku"
  default     = "standard"
}
variable "tags" {
  type        = map(string)
  description = "values for tags"
  default = {
    key   = "env"
    value = "dev"
  }
}

variable "image" {
  type        = map(string)
  description = "values for image"
  default = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
}

variable "disk" {
  type        = map(string)
  description = "values for disk"
  default = {
    osDiskName   = "syst"
    caching      = "ReadWrite"
    createOption = "FromImage"
    diskType     = "Standard_LRS"
  }
}

variable "vm" {
  type        = map(string)
  description = "values for virtual machine"
  default = {
    userName         = "adsadmin"
    pw               = ""
    provisionVmAgent = true
    vmName           = "azrads01"
    vmSize           = "Standard_DS2_v2"
  }
}

variable "root_id" {
  type        = string
  description = "root id value for organization"
}

variable "root_name" {
  type        = string
  description = "root name value for organization"
}

variable "primary_location" {
  type        = string
  description = "primary azure region value for organization"
}

variable "secondary_location" {
  type        = string
  description = "secondary azure region value for organization"
}

variable "identitySubscriptionId" {
  type        = string
  description = "identity subscription id"
  default     = "1d790e78-7852-498d-8087-f5d48686a50e"
}

variable "rsv_sku" {
  type        = string
  description = "values for recovery services vault sku"
  default     = "Standard"
}

variable "pw" {
  type        = string
  description = "Values for password. Will be provided interactively for confidentiality"
}

variable "resource_codes" {
  type        = map(string)
  description = "values for resource codes abbreviations"
  default = {
    prefix           = "azr"
    resource_group   = "rgp"
    key_vault        = "kvt"
    recovery_vault   = "rsv"
    storage          = "sta"
    development      = "dev"
    subnet           = "snt"
    sql              = "sql"
    vnet             = "vnt"
    net_sec_grp      = "nsg"
    public_ip        = "pip"
    bastion          = "bas"
    availaiblity_set = "avs"
  }
}

variable "sta" {
  type        = map(string)
  description = "values for storage account"
  default = {
    kind             = "StorageV2"
    tier             = "Standard"
    replication_type = "LRS"
  }
}
variable "retention_days" {
  type        = number
  description = "values for soft delete retention in days"
  default     = 7
}

variable "nsg_rules_adds" {
  description = "A list of security rules to apply to the network security group."
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
  default = [{
    name                       = "placeholder-adds"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }]
}

variable "nsg_rules_srvs" {
  description = "A list of security rules to apply to the network security group."
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
  default = [{
    name                       = "placeholder-srvs"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }]
}

variable "vnt" {
  type = list(object({
    name             = string
    address_prefix = string
    dns_servers      = list(string)
    subnets          = list(object({
      name           = string
      address_prefix = string
    }))
  }))
  description = "values for virtual network"
  default = {
    name             = "vnt-ads"
    address_prefix = "10.0.0.0/27"
    dns_servers      = ["10.0.0.4", "10.0.0.5"]
    subnets = [
      {
        name           = "adds"
        address_prefix = "10.0.0.0/29"
      },
      {
        name           = "srvs"
        address_prefix = "10.0.0.8/29"
      }
    ]
  }
}
