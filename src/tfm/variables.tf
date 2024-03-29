variable "root_id" {
  type    = string
  default = "org-id"
}

variable "root_name" {
  type    = string
  default = "org-name"
}
variable "target_mg_id" {
  type        = string
  description = "target management group id"
}

variable "target_mg_name" {
  type        = string
  description = "target management group name"
}

variable "primary_location" {
  type    = string
  default = "centralus"
}

variable "secondary_location" {
  type    = string
  default = "eastus2"
}
variable "identitySubscriptionId" {
  type    = string
}
variable "managementSubscriptionId" {
  type    = string
}

variable "iacSubscriptionId" {
  type    = string
}

variable "connectivitySubscriptionId" {
  type    = string
}

variable "umi_name" {
  type        = string
  description = "prefix for user managed identity"
}