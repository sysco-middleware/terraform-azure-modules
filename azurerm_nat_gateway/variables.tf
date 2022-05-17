variable "name" {}
variable "lock_resource" {
  type        = bool
  description = "Adds lock level CanNotDelete to the resource"
  default     = false
}
variable "rg_name" {}
variable "sku_name" {
  type        = string
  description = "(Optional) The SKU which should be used. At this time the only supported value is Standard. Defaults to Standard."
  default     = "Standard"
}
variable "idle_timeout_in_minutes" {
  type        = number
  description = "(Optional) The idle timeout which should be used in minutes. Defaults to 10."
  default     = 10
}
variable "zones" {
  type        = list(string)
  description = "(Optional) A list of availability zones where the NAT Gateway should be provisioned. does not support multiple availability zones. The provided zones are '1,2,3'. Changing this forces a new resource to be created."
  default     = ["1"]
}
variable "vnet_rg_name" {}
variable "vnet_name" {}
variable "snet_names" {
  type        = list(string)
  description = "The name(s) of the subnet to NAT"
  default     = []
}
variable "natgpipa_enabled" {
  type        = bool
  description = "Enables azurerm_nat_gateway_public_ip_prefix_association"
  default     = false
}
variable "natgpipa_objects" {
  type = list(object({
    name    = string
    rg_name = string
  }))
  description = "A list of Public IP prefixes for azurerm_nat_gateway_public_ip_prefix_association"
  default     = []
}
variable "natgpiaa_objects" {
  type = list(object({
    name    = string
    rg_name = string
  }))
  description = "A list of Public IP addresss for azurerm_nat_gateway_public_ip_address_association"
  default     = []
}
variable "tags" {
  type        = map(any)
  description = "A mappinatg of tags to assign to the resource."
  default     = {}
}
