variable "root_id" {
  type    = string
  default = "org-id"
}

variable "root_name" {
  type    = string
  default = "org-name"
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
  default = "1d790e78-7852-498d-8087-f5d48686a50e"
}
variable "pw" {
  type = string
}

variable "managementSubscriptionId" {
  type    = string
  default = "019181ad-6356-46c6-b584-444846096085"
}

variable "connectivitySubscriptionId" {
  type    = string
  default = "e4aad2d8-e670-4807-bf53-63b4a36e0d4a"
}