variable "rgpName" {
  type    = string
  default = "rgp-ads"
}

variable "storage" {
  type = map(object({
    kind             = string
    tier             = string
    replication_type = string
  }))
  default = {
    sta = {
      kind             = "StorageV2"
      tier             = "Standard"
      replication_type = "LRS"
    }
  }
}

variable "vnet" {
  type = map(object({
    vntName       = string
    vntAddrSpaces = list(string)
  }))
  default = {
    vnet = {
      vntName       = "idy-vnt"
      vntAddrSpaces = ["10.0.0.0/28"]
    }
  }
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

variable "kvt" {
  type = map(object({
    sku = string
  }))
  default = {
    kvt = {
      sku = "standard"
    }
  }
}

variable "tags" {
  type = map(string)
  default = {
    key   = "environment"
    value = "Production"
  }
}

variable "image" {
  type = map(object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  }))
  default = {
    image = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2022-Datacenter"
      version   = "latest"
    }
  }
}

variable "disk" {
  type = map(object({
    osDiskName   = string
    caching      = string
    createOption = string
    diskType     = string
  }))
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
  type = map(object({
    userName         = string
    pw               = string
    provisionVmAgent = bool
    vmName           = string
    vmSize           = string
  }))
  default = {
    vm = {
      userName         = "adsadmin"
      pw               = ""
      provisionVmAgent = true
      vmName           = "azrads01"
      vmSize           = "Standard_DS2_v2"
    }
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
  type = string
  default = "1d790e78-7852-498d-8087-f5d48686a50e"
}

variable "rsv" {
  type = map(object({
    sku     = string
    soft_delete_enabled = string
  }))
  default = {
      sku = "Standard"
      soft_delete_enabled = "true"
  }
}