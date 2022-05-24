variable "vnet_name" {}
variable "rg_name" {}
#variable "subnets" {}

variable "subnets" {
  type = list(object({
    name       = string
    cidr       = list(string)
    tags       = list(string)
    endpoints  = list(string) # Endpoints are services that can connect to the Subnet
    delegation = list(string) # The service that can be installed in the Subnet
  }))
  description = "Subnet names, cidr prefixes, service endpoints and subnet deligation"
}

variable "delegation_actions" {
  type        = list(string)
  description = "value"
  default = [
    "Microsoft.Network/networkinterfaces/*",
    "Microsoft.Network/virtualNetworks/subnets/action",
    "Microsoft.Network/virtualNetworks/subnets/join/action",
    "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
    "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action",
    # Microsoft.Network/virtualNetworks/subnets/joinViaServiceEndpoint/action
  ]
}

variable "enforce_private_link_endpoint_network_policies" {
  type        = bool
  description = "(Optional) Enable or Disable network policies for the private link endpoint on the subnet. Setting this to true will Disable the policy and setting this to false will Enable the policy. Default value is false."
  default     = false
}

variable "enforce_private_link_service_network_policies" {
  type        = bool
  description = "(Optional) Enable or Disable network policies for the private link service on the subnet. Setting this to true will Disable the policy and setting this to false will Enable the policy. Default value is false."
  default     = false
}

variable "service_endpoint_policy_ids" {
  type        = list(string)
  description = "(Optional) The list of IDs of Service Endpoint Policies to associate with the subnet. Requires minimum 1 policy if defined."
  default     = null
}