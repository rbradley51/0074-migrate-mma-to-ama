# variable "primary_location" {
#   type = string
#   default = "centralus"
# }

# variable "rgpName" {
#   type = string
#   default = "idy-rgp"
# }

# variable "vntName" {
#   type = string
#   default = "ads-vnt"
# }

# variable "vntAddrSpaces" {
#   type = list(string)
#   default = ["10.0.0.0/16"]
# }

# variable "nsgName" {
#   type = string
#   default = "ads-nsg"
# }

# variable "sntName" {
#   type = string
#   default = "ads-snt"
# }   

# variable "subAddrPrefix" {
#   type = string
#   default = "10.0.1.0/24"
# }

# variable "ads01NicName" {
#   type = string
#   default = "ads01-nic"
# }

# variable "ads01NicConfigName" {
#   type = string
#   default = "ads01-nic-config"
# }

# variable "prvIpAlloc" {
#   type = string
#   default = "Dynamic"
# }   

# variable "vmName" {
#   type = string
#   default = "azr-prd-ads-01"
# }

# variable "vmSize" {
#   type = string
#   default = "Standard_DS2_v2"
# }

# variable "imgPublisher" {
#   type = string
#   default = "MicrosoftWindowsServer"
# }

# variable "imgOffer" {
#   type = string
#   default = "WindowsServer"
# }

# variable "imgSku" {
#     type = string
#     default = "2022-Datacenter"
# }

# variable "imgVersion" {
#     type = string
#     default = "latest"
# }

# variable "osDiskName" {
#     type = string
#     default = "syst"
# }

# variable "caching" {
#     type = string
#     default = "ReadWrite"
# }

# variable "createOption" {
#     type = string
#     default = "FromImage"
# }

# variable "diskType" {
#     type = string
#     default = "Standard_LRS"
# }

# variable "userName" {
#     type = string
#     default = "adsadmin"
# }

# variable "provisionVmAgent" {
#     type = bool
#     default = true
# }

variable "idy" {
  type = object({})
  default = {
    settings = {
      identity = {
        config = {
          primary_location = "centralus"
          rgpName          = "idy-rgp"
          sta = {
            kind             = "StorageV2"
            tier             = "Standard"
            replication_type = "LRS"
          }
          kvt = {
            sku = "standard"
          }
          tags = {
            key   = "environment"
            value = "Production"
          }
          vnet = {
            vntName       = "idy-vnt"
            vntAddrSpaces = ["10.0.0.0/28"]
            subnet = {
              nsgName       = "ads-nsg"
              sntName       = "ads-snt"
              subAddrPrefix = "10.0.0.0/29"
              nsgName       = "ads-nsg"
              nic = {
                ads01NicName       = "ads01-nic"
                ads01NicConfigName = "ads01-nic-config"
                prvIpAlloc         = "Dynamic"
              }
            }
          }
          image = {
            publisher = "MicrosoftWindowsServer"
            offer     = "WindowsServer"
            sku       = "2022-Datacenter"
            version   = "latest"
          }
          disk = {
            osDiskName   = "syst"
            caching      = "ReadWrite"
            createOption = "FromImage"
            diskType     = "Standard_LRS"
          }
          avset = {
            avsetName = "AvSetADS"
          }
          vm = {
            userName         = "adsadmin"
            pw               = ""
            provisionVmAgent = true
            vmName           = "azrads01"
            vmSize           = "Standard_DS2_v2"
          }
        }
      }
    }
  }
}
variable "pw" {
  type    = string
  default = ""
}
