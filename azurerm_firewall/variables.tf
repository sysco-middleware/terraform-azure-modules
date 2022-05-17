variable "name" {}
variable "rg_name" {}
variable "vnet_name" {}

variable "pipa_id" {
  type        = string
  description = "The Public IP must have a Static allocation and Standard sku."
}

variable "pipa_id_mgmt" {
  type        = string
  description = "The Public IP must have a Static allocation and Standard sku."
  default     = null
}

variable "sku_name" {
  type        = string
  description = "(Optional) Sku name of the Firewall. Possible values are AZFW_Hub and AZFW_VNet. Changing this forces a new resource to be created."
  default     = "AZFW_VNet"
  validation {
    condition     = contains(["AZFW_Hub", "AZFW_VNet"], var.sku_name)
    error_message = "Variable \"sku_name\" must either be \"AZFW_Hub\" or \"AZFW_VNet\"."
  }
}

variable "sku_tier" {
  type        = string
  description = "(Optional) Sku tier of the Firewall. Possible values are Premium and Standard. Changing this forces a new resource to be created"
  default     = "Standard"
  validation {
    condition     = contains(["Standard", "Premium"], var.sku_tier)
    error_message = "Variable \"sku_name\" must either be \"Standard\" or \"Premium\"."
  }
}

variable "dns_servers" {
  type        = list(string)
  description = "(Optional) A list of DNS servers that the Azure Firewall will direct DNS traffic to the for name resolution."
  default     = []
  validation {
    condition     = length(local.dns_servers) > 0
    error_message = "The Variable 'dns_servers' must have atleast one item."
  }
}

variable "snet_fw_name" {
  type        = string
  description = "The Subnet used for the Firewall must have the name AzureFirewallSubnet and the subnet mask must be at least a /26."
  default     = "AzureFirewallSubnet"
  validation {
    condition     = try(var.snet_fw_name == "AzureFirewallSubnet")
    error_message = "The 'snet_fw_name' variable for the Firewall must have the name AzureFirewallSubnet."
  }
}
variable "snet_mgnt_name" {
  type        = string
  description = "The Subnet used for the Firewall must have the name 'AzureFirewallManagementSubnet' ubnet and the subnet mask must be at least a /26."
  default     = "AzureFirewallManagementSubnet"
  validation {
    condition     = try(var.snet_mgnt_name == "AzureFirewallManagementSubnet")
    error_message = "The 'snet_mgnt_name' variable for the Firewall must have the name AzureFirewallManagementSubnet."
  }
}

variable "firewall_policy_id" {
  type        = string
  description = "(Optional) The ID of the Firewall Policy applied to this Firewall."
  default     = null
}

variable "threat_intel_mode" {
  type        = string
  description = "(Optional) The operation mode for threat intelligence-based filtering. Possible values are: Off, Alert, Deny and \"\" (empty string). Defaults to Alert."
  default     = "Alert"
  validation {
    condition     = can(regex("Off|Alert|Deny", var.threat_intel_mode)) || var.threat_intel_mode == ""
    error_message = "The variable 'threat_intel_mode' must be Off, Alert (Default), Deny or \"\"."
  }
}

variable "tags" {
  type        = map(any)
  description = "A mapping of tags to assign to the resource."
  default     = {}
}
