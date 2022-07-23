variable "name" {}
variable "rg_name" {}
variable "location" {
  type        = string
  description = "The location/region where the virtual network is created. Changing this forces a new resource to be created. Uses resource group location by default"
  default     = null
}

variable "address_prefix" {
  type        = string
  description = "(Optional) The Address Prefix which should be used for this Virtual Hub. Changing this forces a new resource to be created. The address prefix subnet cannot be smaller than a /24. Azure recommends using a /23."
  default     = null
}

variable "sku" {
  type        = string
  description = "(Optional) The SKU of the Virtual Hub. Possible values are Basic and Standard. Changing this forces a new resource to be created."
  default     = "Basic"
  validation {
    condition     = can(regex("Basic|Standard", var.sku))
    error_message = "Variable 'sku' must either be 'Basic' (Default) or 'Standard'."
  }
}

variable "virtual_wan_id" {
  type        = string
  description = "(Optional) The ID of a Virtual WAN within which the Virtual Hub should be created. Changing this forces a new resource to be created."
  default     = null
}

variable "routes" {
  type = object({
    address_prefixes    = list(string) # (Required) A list of Address Prefixes.
    next_hop_ip_address = string       # - (Required) The IP Address that Packets should be forwarded to as the Next Hop.
  })
  default = []
}

variable "tags" {
  type        = map(any)
  description = "A mapping of tags to assign to the resource."
  default     = {}
}