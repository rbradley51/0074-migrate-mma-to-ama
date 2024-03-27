variable "rgp_idy" {
  type        = string
  description = "values for resource group name"
  default     = "rgp-idy"
}

variable "rgp_iac" {
  type        = string
  description = "values for resource group name"
  default     = "rgp-iac"
  
}
variable "root_id" {
  type        = string
  description = "root id value for organization"
}

variable "root_name" {
  type        = string
  description = "root name value for organization"
}

variable "target_mg_id" {
  type        = string
  description = "root id value for organization"
}

variable "target_mg_name" {
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

variable "umi_name" {
  type        = string
  description = "prefix for user managed identity"
  default     = "umi-ama-mig-001"
}

variable "umi_pol_name" {
  type        = string
  description = "prefix for user managed identity policy"
  default     = "umi-ama-pol-001"
}

variable "umi_pol_id" {
  type        = string
  description = "user managed identity policy id"
  default = "/subscriptions/e25024e7-c4a5-4883-80af-9e81b2f8f689/resourceGroups/rgp-iac/providers/Microsoft.ManagedIdentity/userAssignedIdentities/umi-ama-pol-001"
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
    name = "dce"
    lifecycle = {
      create_before_destroy = true
    }
  }

}
variable "ama_initiative_assignment" {
  type = map(string)
  description = "Enable Azure Monitor for VMs AMA"
  default = {
    name_dcr = "enable-ama-dcr"
    name_dcr_ext = "enable-ama-dcr-ext"
    display_name = "Enable Azure Monitor for VMs with Azure Monitoring Agent(AMA)"
    policy_set_def_id = "/providers/Microsoft.Authorization/policySetDefinitions/924bfe3a-762f-40e7-86dd-5c8b95eb09e6"
    effect = "DeployIfNotExists"
    dcrResourceId = "/subscriptions/019181ad-6356-46c6-b584-444846096085/resourceGroups/rgp-idy/providers/Microsoft.Insights/dataCollectionRules/dcr"
    dcrExtResourceId = "/subscriptions/019181ad-6356-46c6-b584-444846096085/resourceGroups/rgp-idy/providers/Microsoft.Insights/dataCollectionRules/dcr-extensions"
    assignment_id_dcr = "/providers/microsoft.management/managementgroups/org-id-platform/providers/microsoft.authorization/policyassignments/enable-az-monitor-ama-dcr"
    assignment_id_dcr_ext = "/providers/microsoft.management/managementgroups/org-id-platform/providers/microsoft.authorization/policyassignments/enable-az-monitor-ama-dcr-ext"
    remediation_name_dcr = "remediate-az-monitor-ama-dcr"
    remediation_name_dcr_ext = "remediate-az-monitor-ama-dcr-ext"
  }
}

variable "umi_vm_policy" {
  type = map(string)
  description = "[Preview]: Assign Built-In User-Assigned Managed Identity to Virtual Machines"
  default = {
    name = "d367bd60-64ca-4364-98ea-276775bddd94"
    assignment_name = "assign-umi-vm-policy"
    defId  = "/providers/Microsoft.Authorization/policyDefinitions/d367bd60-64ca-4364-98ea-276775bddd94"
  }
}

variable "ama_init_bool" {
  type        = map(bool)
  description = "Boolean values for Azure Monitor for VMs with Azure Monitoring Agent(AMA)"
  default     = {
    enableProcessesAndDependencies = false
    bringYourOwnUserAssignedManagedIdentity = true
    scopeToSupportedImages = true
  }  
}

variable "mgt_law" {
  type        = map(string)
  description = "management log analytics workspace settings from landing zone"
  default = {
    name = "log-management"
    rgp  = "rg-management"
  }
}


variable "hub_vnt" {
  type        = map(string)
  description = "hub virtual network settings from landing zone"
  default = {
    name = "vnet-hub"
    rgp  = "rg-connectivity"
  }
}

variable "hvn" {
  type        = list(string)
  description = "address spaces for hub virtual network"
  default = ["10.0.0.0/16"]
}

variable "managementSubscriptionId" {
  type    = string
  default = "019181ad-6356-46c6-b584-444846096085"
}

variable "connectivitySubscriptionId" {
  type    = string
  default = "e4aad2d8-e670-4807-bf53-63b4a36e0d4a"
}

variable "dcr_type" {
  type        = map(string)
  description = "DCR rule types and name"
  default = {
    dcr = "dcr"
    dcr-ext  = "dcr-extensions"
  }
}

# az policy remediation create -n myRemediation --policy-assignment eeb18edc813c42d0ad5a9eab --definition-reference-id auditVMPolicyReference