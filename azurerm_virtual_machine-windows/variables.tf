variable "name" {}
variable "lock_resource" {
  type        = bool
  description = "Adds lock level CanNotDelete to the resource"
  default     = false
}
variable "rg_name" {}
variable "nic_name" {}
variable "disk_name" {}
variable "kv_name" {}
variable "cert_name" {}
variable "vm_size" {
  type        = string
  description = "(Required) Specifies the size of the Virtual Machine. See also Azure VM Naming Conventions. https://docs.microsoft.com/en-us/azure/virtual-machines/dv2-dsv2-series"
  default     = "Standard_DS2_v2"
}
variable "computer_name" {
  type        = string
  description = "(Required) Specifies the name of the Virtual Machine."
}
variable "admin_user" {
  type        = string
  description = "(Required) Specifies the name of the local administrator account."
}
variable "admin_pass" {
  type        = string
  description = "(Required for Windows, Optional for Linux) The password associated with the local administrator account."
}
variable "timezone" {
  # https://jackstromberg.com/2017/01/list-of-time-zones-consumed-by-azure/
  type        = string
  description = "(Optional) Specifies the time zone of the virtual machine"
  default     = "Central Europe Standard Time"
}
variable "tags" {
  type        = map(any)
  description = "A mapping of tags to assign to the resource."
  default     = {}
}
