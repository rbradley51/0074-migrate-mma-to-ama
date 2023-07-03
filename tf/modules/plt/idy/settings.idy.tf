# Configure custom identity resources settings
locals {
  configure_identity_resources = {
    settings = {
      identity = {
        config = {
          rgpName = "idy-rgp"
          vnet = {
            vntName       = "idy-vnt"
            vntAddrSpaces = ["10.0.0.0/28"]
            subnet = {
              nsgName         = "ads-nsg"
              sntName         = "ads-snt"
              subAddrPrefixes = ["10.0.0.0/29"]
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

          vm = {
            userName         = "adsadmin"
            pw               = "P@ssw0rd1234"
            provisionVmAgent = true
            vmName           = "azr-prd-ads-01"
            vmSize           = "Standard_DS2_v2"
          }
        }
      }
    }
  }
}

