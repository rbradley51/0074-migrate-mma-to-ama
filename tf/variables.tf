variable "root_id" {
  type = string
  default = "orgid"
}

variable "root_name" {
  type = string
  default = "organization id"
}

variable "primary_location" {
  type = string
  default = "centralus"
}

variable "secondary_location" {
  type = string
  default = "eastus2"
}
variable "identitySubscriptionId" {
  type = string
  default = "1d790e78-7852-498d-8087-f5d48686a50e"
}
variable "pw" {
  type    = string
  default = "InvalidUnusedPassword123!"
}