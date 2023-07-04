# Configure custom identity resources settings
locals {
  configure_identity_resources = {
    settings = {
      identity = {
        config = {
          primary_location = "centralus"
          rgpName = "idy-rgp"
          sta = {
            kind = "StorageV2"
            tier = "Standard"
            replication_type = "LRS"
          }
          kvt = {
            sku = "standard"
          }
          tags = {
            key = "environment"
            value = "Production"
          }
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

