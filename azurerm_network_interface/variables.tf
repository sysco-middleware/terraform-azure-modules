variable "name" {}
variable "lock_resource" {
  type        = bool
  description = "Adds lock level CanNotDelete to the resource"
  default     = false
}
variable "rg_name" {}
variable "nsg_rg_name" {}
variable "nsg_name" {}

variable "ip_configurations" {
  type = list(object({
    name                      = string # (Required) A name used for this IP Configuration.
    subnet_id                 = string # (Optional) The ID of the Subnet where this Network Interface should be located in.
    private_ipaddr_allocation = string # (Required) The allocation method used for the Private IP Address. Possible values are Dynamic and Static.
    private_ip_address        = string # Optional) The Static IP Address which should be used.
    primary                   = bool   # (Optional) Is this the Primary IP Configuration? Must be true for the first ip_configuration when multiple are specified. Defaults to false.
    # TODO: gateway_load_balancer_frontend_ip_configuration_id
    # TODO: private_ip_address_version - (Optional) The IP Version to use. Possible values are IPv4 or IPv6. Defaults to IPv4.
    # TODO: private_ip_address_allocation - (Required) The allocation method used for the Private IP Address. Possible values are Dynamic and Static

  }))
  description = "(Required) One or more ip_configuration blocks as defined below"
  default     = []
}
variable "dns_servers" {
  type        = list(string)
  description = "(Optional) A list of IP Addresses defining the DNS Servers which should be used for this Network Interface. Configuring DNS Servers will override the DNS Servers defined on the Virtual Network."
  default     = []
}
variable "enable_ip_forwarding" {
  type        = bool
  description = "(Optional) Should IP Forwarding be enabled? Defaults to false"
  default     = false
}
variable "internal_dns_name_label" {
  type        = string
  description = " (Optional) The (relative) DNS Name used for internal communications between Virtual Machines in the same Virtual Network."
  default     = null
}
variable "enable_accelerated_networking" {
  type        = bool
  description = "(Optional) Should Accelerated Networking be enabled? Defaults to false. Only certain Linux Virtual Machine sizes are supported for Accelerated Networking - more information can be found in this document."
  default     = false
}
variable "tags" {
  type        = map(any)
  description = "A mapping of tags to assign to the resource."
  default     = {}
}
