variable "name" {}
variable "rg_name" {}
variable "location" {
  type        = string
  description = "The location/region where the virtual network is created. Changing this forces a new resource to be created. Uses resource group location by default"
  default     = null
}

variable "virtual_hub_id" {
  type        = string
  description = "(Required) The ID of the Virtual Hub within which this VPN Gateway should be created. Changing this forces a new resource to be created."
}

variable "bgp_route_translation_for_nat_enabled" {
  type        = bool
  description = "(Optional) Is BGP route translation for NAT on this VPN Gateway enabled? Defaults to false."
  default     = false
}

variable "bgp_settings" {
  type = object({
    asn                   = string       # (Required) The ASN of the BGP Speaker. Changing this forces a new resource to be created.
    peer_weight           = number       # (Required) The weight added to Routes learned from this BGP Speaker. Changing this forces a new resource to be created.
    instance_0_custom_ips = list(string) # (Required) A list of custom BGP peering addresses to assign to instance 0.
    instance_1_custom_ips = list(string) # (Required) A list of custom BGP peering addresses to assign to instance 1.
  })
  default = {
    asn                   = null
    peer_weight           = 100
    instance_0_custom_ips = []
    instance_1_custom_ips = []
  }
}

variable "routing" {
  type        = string
  description = "(Optional) Azure routing preference lets you to choose how your traffic routes between Azure and the internet. You can choose to route traffic either via the Microsoft network (default value, Microsoft Network), or via the ISP network (public internet, set to Internet). More context of the configuration can be found in the Microsoft Docs to create a VPN Gateway. Changing this forces a new resource to be created."
  default     = "Microsoft Network"
  validation {
    condition     = can(regex("Microsoft Network|Internet", var.routing))
    error_message = "Variable 'routing' must either be 'Microsoft Network' (Default) or 'Internet'."
  }
}

variable "scale_unit" {
  type        = number
  description = "(Optional) The Scale Unit for this VPN Gateway. Defaults to 1"
  default     = 1
  validation {
    condition     = var.scale_unit >= 1 && var.scale_unit <= 10
    error_message = "Variable 'scale_unit' can be between 1 (Default) and 10."
  }
}

variable "tags" {
  type        = map(any)
  description = "A mapping of tags to assign to the resource."
  default     = {}
}