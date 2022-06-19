variable "name" {}
variable "rg_name" {}
variable "disable_propagation" {
  type        = bool
  description = "(Optional) Boolean flag which controls propagation of routes learned by BGP on that route table. True means disable."
  default     = false
}

variable "routes" {
  type = list(object({
    name                   = string # (Required) The name of the Backend Address Pool.
    address_prefix         = string # (Optional) A list of IP Addresses in CIDR which should be part of the Backend Address Pool.
    next_hop_type          = string # (Required) The type of Azure hop the packet should be sent to. Possible values are VirtualNetworkGateway, VnetLocal, Internet, VirtualAppliance and None
    next_hop_in_ip_address = string # (Optional) Contains the IP address packets should be forwarded to. Next hop values are only allowed in routes where the next hop type is VirtualAppliance.
  }))
  validation {
    condition = alltrue([
      for item in var.routes : can(regex("VirtualNetworkGateway|VnetLocal|VirtualAppliance|Internet|None", item.next_hop_type))
    ])
    error_message = "The list variable 'routes' must one of: VirtualNetworkGateway, VnetLocal, Internet, VirtualAppliance and None."
  }
}

variable "subnet_ids" {
  type        = list(string)
  description = "(Required/Optional) A list of Subnet IDs the Route Table which should be associated with. Changing this forces a new resource to be created."
  default     = []
}

variable "tags" {
  type        = map(any)
  description = "A mapping of tags to assign to the resource."
  default     = {}
}
