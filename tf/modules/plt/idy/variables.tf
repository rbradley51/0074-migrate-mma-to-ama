variable "rgpName" {
  type    = string
  description = "values for resource group name"
  default = "rgp-ads"
}

variable "vnetName" {
  type = string
  description = "values for virtual network name"
  default = "vnt-ads"
}

variable vntAddrSpaces {
  type = list(string)
  description = "values for virtual network address spaces"
  default = ["10.0.0.0/28"]
}

variable "subnets" {
  type = map(object({
    name = string
    cidr = string
  }))
  description = "values for subnets"
  default = {
    subnet1 = {
      name = "adds-snet"
      cidr = "10.0.0.0/29"
    }
  }
}

variable "nic" {
  type = map(object({
    name       = string
    prvIpAlloc = string
  }))
  description = "values for network interface"
  default = {
    nic = {
      name       = "ads01-nic"
      prvIpAlloc = "Dynamic"
    }
  }
}

variable "kvt_sku" {
  type = string
  description = "values for key vault sku"
  default = "standard"
  }
variable "tags" {
  type = map(string)
  description = "values for tags"
  default = {
    key   = "env"
    value = "dev"
  }
}

variable "image" {
  type = map(string)
  description = "values for image"
  default = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
}

variable "disk" {
  type = map(string)
  description = "values for disk"
  default = {
      osDiskName   = "syst"
      caching      = "ReadWrite"
      createOption = "FromImage"
      diskType     = "Standard_LRS"
  }
}

variable "vm" {
  type = map(string)
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
  type = string
  description = "root id value for organization"
}

variable "root_name" {
  type = string
  description = "root name value for organization"
}

variable "primary_location" {
  type = string
  description = "primary azure region value for organization"
}

variable "secondary_location" {
  type = string
  description = "secondary azure region value for organization"
}

variable "identitySubscriptionId" {
  type    = string
  description = "identity subscription id"
  default = "1d790e78-7852-498d-8087-f5d48686a50e"
}

variable "rsv_sku" {
  type    = string
  description = "values for recovery services vault sku"
  default = "Standard"
}

variable "pw" {
  type = string
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
