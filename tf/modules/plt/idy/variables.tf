variable "rgpName" {
  type    = string
  default = "rgp-ads"
}

variable "vnetName" {
  type = string
  default = "vnt-ads"
}

variable vntAddrSpaces {
  type = list(string)
  default = ["10.0.0.0/28"]
}

variable "subnets" {
  type = map(object({
    name = string
    cidr = string
  }))
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
  default = {
    key   = "env"
    value = "dev"
  }
}

variable "image" {
  type = map(string())
  default = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
}

variable "disk" {
  type = map(string())
  default = {
    disk = {
      osDiskName   = "syst"
      caching      = "ReadWrite"
      createOption = "FromImage"
      diskType     = "Standard_LRS"
    }
  }
}

variable "vm" {
  type = map(string())

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
}

variable "root_name" {
  type = string
}

variable "primary_location" {
  type = string
}

variable "secondary_location" {
  type = string
}

variable "identitySubscriptionId" {
  type    = string
  default = "1d790e78-7852-498d-8087-f5d48686a50e"
}

variable "rsv_sku" {
  type    = string
  default = "Standard"
}

variable "pw" {
  type = string
}

variable "resource_codes" {
  type        = map((string))
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
