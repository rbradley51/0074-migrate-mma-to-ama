variable "rgp" {
  type = map(object({
    rgpName     = string
    rgpLocation = string
  }))
  default = {
    rgp = {
      rgpName     = "rgp-ads"
      rgpLocation = primary_location
    }
  }
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
    subnet = map(object({
      sntName         = string
      subAddrPrefix = string
      nsgName         = string
      nic = map(object({
        ads01NicName       = string
        ads01NicConfigName = string
        prvIpAlloc         = string
      }))
    }))
  }))
  default = {
          vnet = {
            vntName       = "idy-vnt"
            vntAddrSpaces = ["10.0.0.0/28"]
            subnet = {
              nsgName         = "ads-nsg"
              sntName         = "ads-snt"
              subAddrPrefix = "10.0.0.0/29"
              nsgName         = "ads-nsg"
              nic = {
                ads01NicName       = "ads01-nic"
                ads01NicConfigName = "ads01-nic-config"
                prvIpAlloc         = "Dynamic"
              }
            }
          }
  }

variable "keyvault" {
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
    key = "environment"
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