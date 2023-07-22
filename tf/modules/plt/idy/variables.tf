variable "rgpName" {
  type        = string
  description = "values for resource group name"
  default     = "rgp-idy"
}

variable "idy_nics" {
  type        = list(map(string))
  description = "values for network interface"
  default = [{
    name       = "ads01-nic"
    prvIpAlloc = "Static"
    prvIpAddr  = "10.0.0.4"
    ipconfig   = "ads01-ipconfig"
    },
    {
      name       = "ads02-nic"
      prvIpAlloc = "Static"
      prvIpAddr  = "10.0.0.5"
      ipconfig   = "ads02-ipconfig"
    },
    {
      name       = "svr01-nic"
      prvIpAlloc = "Static"
      prvIpAddr  = "10.0.0.12"
      ipconfig   = "svr01-ipconfig"
    }
  ]
}
variable "svr_nics" {
  type        = map(string)
  description = "values for network interface"
  default = {
    name       = "svr01-nic"
    prvIpAlloc = "Static"
    prvIpAddr  = "10.0.0.12"
    ipconfig   = "svr01-ipconfig"
  }
}
variable "pw" {
  type        = string
  description = "Values for password. Will be provided interactively for confidentiality"
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

variable "avs_adds" {
  type = object({
    update_domain = number
    fault_domain  = number
    managed       = bool
  })
  description = "values for availability set adds"
  default = {
    update_domain = 5
    fault_domain  = 3
    managed       = true
  }
}

variable "avs_idy" {
  type = list(object({
    name          = string
    update_domain = number
    fault_domain  = number
    managed       = bool
  }))
  description = "values for availability set for the identity resources"
  default = [{
    name          = "avs-adds"
    update_domain = 5
    fault_domain  = 3
    managed       = true
    },
    {
      name          = "avs-svrs"
      update_domain = 5
      fault_domain  = 3
      managed       = true
  }]
}

variable "vms" {
  type = list(object({
    vmName = string
    vmSize = string
    image  = map(string)
    disk_os = object({
      osDiskName   = string
      caching      = string
      createOption = string
      diskType     = string
      diskSizeGB   = number
    })
    disk_data = object({
      dataDiskName = string
      caching      = string
      createOption = string
      diskType     = string
      diskSizeGB   = number
      lun          = number
    })
    os_profile = map(string)
    windows_config = object({
      provision_vm_agent        = bool
      enable_automatic_upgrades = bool
    })
  }))
  description = "Values for virtual machines"
  default = [
    {
      vmName           = "azrads01"
      provisionVmAgent = true
      vmSize           = "Standard_B2als_v2"
      image = {
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = "2022-datacenter-azure-edition-smalldisk"
        version   = "latest"
      }
      disk_os = {
        osDiskName   = "syst"
        caching      = "ReadWrite"
        createOption = "FromImage"
        diskType     = "Standard_LRS"
        diskSizeGB   = 32
      }
      disk_data = {
        dataDiskName = "data"
        caching      = "ReadWrite"
        createOption = "Empty"
        diskType     = "Standard_LRS"
        diskSizeGB   = 32
        lun          = 2
      }
      os_profile = {
        admin_username = "adsadmin"
        admin_password = "InvalidPlaceHolderPw@1253!"
      }

      windows_config = {
        provision_vm_agent        = true
        enable_automatic_upgrades = true
      }
    },
    {
      vmName           = "azrads02"
      provisionVmAgent = true
      vmSize           = "Standard_B2als_v2"
      image = {
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = "2022-datacenter-azure-edition-smalldisk"
        version   = "latest"
      }
      disk_os = {
        osDiskName   = "syst"
        caching      = "ReadWrite"
        createOption = "FromImage"
        diskType     = "Standard_LRS"
        diskSizeGB   = 32
      }
      disk_data = {
        dataDiskName = "data"
        caching      = "ReadWrite"
        createOption = "Empty"
        diskType     = "Standard_LRS"
        diskSizeGB   = 32
        lun          = 2
      }
      os_profile = {
        admin_username = "adsadmin"
        admin_password = "InvalidPlaceHolderPw@1253!"
      }

      windows_config = {
        provision_vm_agent        = true
        enable_automatic_upgrades = true
      }
    },
    {
      vmName           = "azrsvr01"
      provisionVmAgent = true
      vmSize           = "Standard_B2als_v2"
      image = {
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = "2022-datacenter-azure-edition-smalldisk"
        version   = "latest"
      }
      disk_os = {
        osDiskName   = "syst"
        caching      = "ReadWrite"
        createOption = "FromImage"
        diskType     = "Standard_LRS"
        diskSizeGB   = 32
      }
      disk_data = {
        dataDiskName = "data"
        caching      = "ReadWrite"
        createOption = "Empty"
        diskType     = "Standard_LRS"
        diskSizeGB   = 32
        lun          = 2
      }
      os_profile = {
        admin_username = "adsadmin"
        admin_password = "InvalidPlaceHolderPw@1253!"
      }
      windows_config = {
        provision_vm_agent        = true
        enable_automatic_upgrades = true
      }
    }
  ]
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

# variable "pw" {
#   type        = string
#   description = "Values for password. Will be provided interactively for confidentiality"
# }

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
    kind                  = "StorageV2"
    tier                  = "Standard"
    replication_type      = "LRS"
    container_name        = "azr-ama-container"
    container_access_type = "private"
  }
}
variable "retention_days" {
  type        = number
  description = "values for soft delete retention in days"
  default     = 7
}

variable "nsg_name" {
  type        = list(string)
  description = "values for network security group"
  default = [
    "nsg-adds",
    "nsg-svrs"
  ]
}

variable "nsg_rule_sets" {
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
    name                       = "adds-place-holder"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    },
    {
      name                       = "svrs-place-holder"
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
variable "vntName" {
  type        = string
  description = "values for virtual network name"
  default     = "azr-vnt"
}

variable "vntAddressPrefixes" {
  type        = list(string)
  description = "values for virtual network address prefix"
  default     = ["10.0.0.0/24"]
}
variable "dns_servers" {
  type        = list(string)
  description = "values for dns servers"
  default     = ["10.0.0.4", "10.0.0.5"]
}
variable "subnets" {
  type = list(object({
    name           = string
    address_prefix = string
  }))
  description = "values for subnets"
  default = [
    {
      name           = "adds"
      address_prefix = "10.0.0.0/29"
    },
    {
      name           = "svrs"
      address_prefix = "10.0.0.8/29"
    },
    {
      name           = "AzureBastionSubnet"
      address_prefix = "10.0.0.64/26"
    }
  ]
}

variable "bastion" {
  type = object({
    name              = string
    allocation_method = string
    sku               = string
    public_ip = object({
      name              = string
      sku               = string
      allocation_method = string
    })
    ipconfig = object({
      name = string
    })
  })
  description = "values for bastion"
  default = {
    name              = "azr-idy-bas"
    allocation_method = "Static"
    sku               = "Standard"
    public_ip = {
      name              = "azr-idy-bas-pip"
      sku               = "Standard"
      allocation_method = "Static"
    }
    ipconfig = {
      name = "azr-bas-ipconfig"
    }
  }
}

variable "aaa" {
  type        = map(string)
  description = "values for automation account"
  default = {
    name = "azr-idy-aaa"
    sku  = "Basic"
  }
}

variable "law" {
  type        = map(string)
  description = "values for log analytics workspace"
  default = {
    name              = "azr-idy-law"
    sku               = "PerGB2018"
    retention_in_days = 30
  }
}

variable "boot_diag" {
  type        = bool
  description = "enable boot diagnostics for virtual machines"
  default     = true
}
variable "umi_prefix" {
  type        = string
  description = "prefix for user managed identity"
  default     = "azr-umi"
}

variable "ama_dce" {
  type = object({
    name = string
    lifecycle = object({
      create_before_destroy = bool # not used
    }) 
  })
  description = "values for diagnostic collection endpoint"
  default = {
    name = "idy-dce"
    lifecycle = {
      create_before_destroy = true
    }
  }

}
variable "ama_dcr" {
  type = object({
    name = string
    destinations = object({
      log_analytics = object({
        workspace_resource_id = string
        name                  = string
      })
      event_hub = object({
        event_hub_id = string
      })
      storage_blob = object({
        storage_account_id = string
        container_name     = string
        name               = string
      })
      azure_monitor_metrics = object({
        name = string
      })
      data_flow_metrics = object({
        streams      = list(string)
        destinations = list(string)
      })
      data_flow_logs = object({
        streams      = list(string)
        destinations = list(string)
      })
      data_flow_kql = object({
        streams       = list(string)
        destinations  = list(string)
        output_stream = string
        transform_kql = string
      })
      data_sources = object({
        syslog = object({
          facility_names = list(string)
          log_levels     = list(string)
          name           = string
        })
        iis_log = object({
          streams         = list(string)
          name            = string
          log_directories = list(string)
        })
        log_file = object({
          name         = string
          format       = string
          streams      = list(string)
          file_pattern = list(string)
          settings = object({
            text = object({
              record_start_timestamp_format = string
            })
          })
        })
        performance_counter = object({
          streams                       = list(string)
          name                          = string
          sampling_frequency_in_seconds = number
          counter_specifiers            = list(string)
        })
        windows_event_log = object({
          streams        = list(string)
          x_path_queries = list(string)
        })
      })
    })
  })
  description = "values for diagnostic settings"
  default = {
    name = "azr-idy-dcr"
    destinations = {
      log_analytics = {
        name = "idy-law"
      }
      event_hub = {
        event_hub_id = "/subscriptions/1d790e78-7852-498d-8087-f5d48686a50e/resourcegroups/rgp-idy/providers/microsoft.eventhub/namespaces/azr-idy-ehb"
      }
      storage_blob = {
        storage_account_id = "/subscriptions/1d790e78-7852-498d-8087-f5d48686a50e/resourcegroups/rgp-idy/providers/microsoft.storage/storageaccounts/azridysta"
        container_name     = "idy-dcr"
        name               = "idy-dcr"
      }
      azure_monitor_metrics = {
        name = ["InsightsMetrics"]
      }
      data_flow_metrics = {
        streams      = [
          "Microsoft-Event",
          Microsoft-Perf,
          Microsoft-Syslog,
          Microsoft-WindowsEvent
          ]
        destinations = ["azr-idy-law"]
      }
      data_flow_logs = {
        streams      = ["idy-law"]
        destinations = ["idy-dcr"]
      }
      data_flow_kql = {
        streams       = ["idy-law"]
        destinations  = ["idy-dcr"]
        output_stream = "idy-law"
        transform_kql = "source | project TimeGenerated=Time, Computer, Message=AdditionalContext"
      }
      data_sources = {
        syslog = {
          facility_names = ["idy-law"]
          log_levels     = ["idy-law"]
          name           = "example-datasource-syslog"
        }
        iis_log = {
          streams         = ["idy-law"]
          name            = "example-datasource-iis"
          log_directories = ["idy-law"]
        }
        log_file = {
          name         = "example-datasource-logfile"
          format       = "text"
          streams      = ["idy-law"]
          file_pattern = ["idy-law"]
          settings = {
            text = {
              record_start_timestamp_format = "ISO 8601"
            }
          }
        }
        performance_counter = {
          streams                       = ["idy-law", "idy-law"]
          name                          = "example-datasource-perfcounter"
          sampling_frequency_in_seconds = 60
          counter_specifiers            = ["Processor (*)\\% Processor Time"]
        }
        windows_event_log = {
          streams        = ["idy-law"]
          x_path_queries = ["idy-law"]
        }
      }
    }
  }
}
variable "law_solutions" {
  type        = list(string)
  description = "values for monitoring solutions"
  default = [
    "AgentHealthAssessment",
    "AntiMalware",
    "ChangeTracking",
    "Security",
    "SecurityInsights",
    "ServiceMap",
    "SQLAssessment",
    "SQLVulnerabilityAssessment",
    "SQLAdvancedThreatProtection",
    "Updates",
    "VMInsights",
    "ContainerInsights"
  ]
}

variable "ehb" {
  type        = object({
    namespace = string
    sku  = string
    capacity = number
    name = string
    partition_count = number
    message_retention = number
  })
  description = "values for event hub namespace"
  default = {
    namespace = "azr-idy-ehn"
    sku  = "Standard"
    capacity = 1
    name = "azr-idy-ehb"
    partition_count = 2
    message_retention = 1
  }
}