variable "name" {}
variable "rg_name" {}

variable "certificate" {
  type = object({
    kv_secret_id = string # (Required) The ID of the Key Vault, where the secret or certificate is stored.
    name         = string # (Required) The name of the certificate.
  })
  description = "TLS certifcate for firewall policy"
}

variable "base_policy_id" {
  type        = string
  description = "(Optional) The ID of the base Firewall Policy."
  default     = null
}

variable "intrusion_mode" {
  type        = string
  description = "(Optional) In which mode you want to run intrusion detection: Off, Alert, or Deny. Default is Alert."
  default     = "Alert"

  validation {
    condition     = can(regex("Alert|Off|Deny", var.intrusion_mode))
    error_message = "The variable 'intrusion_mode' must be either Alert (Default), Off or Deny."
  }
}

variable "intrusion_signature_overrides" {
  type = list(object({
    id    = string # (Optional) 12-digit number (id) which identifies your signature.
    state = string # (Optional) state can be any of "Off", "Alert" or "Deny".
  }))
  description = "Intrusion signature overrides."
  default     = []
}

variable "intrusion_traffic_bypasses" {
  type = list(object({
    name                  = string
    protocol              = string       #  (Required) The protocols any of "ANY", "TCP", "ICMP", "UDP" that shall be bypassed by intrusion detection.
    description           = string       #  (Optional) The description for this bypass traffic setting.
    destination_addresses = list(string) # (Optional) Specifies a list of destination IP addresses that shall be bypassed by intrusion detection.
    destination_ip_groups = list(string) # (Optional) Specifies a list of destination IP groups that shall be bypassed by intrusion detection
    destination_ports     = list(string) # (Optional) Specifies a list of destination IP ports that shall be bypassed by intrusion detection.
    source_addresses      = list(string) # (Optional) Specifies a list of source addresses that shall be bypassed by intrusion detection.
    source_ip_groups      = list(string) # (Optional) Specifies a list of source ip groups that shall be bypassed by intrusion detection.
  }))
  description = "Intrusion traffic bypass."
  default     = []
}

variable "private_ip_ranges" {
  type        = list(string)
  description = "(Optional) A list of private IP ranges to which traffic will not be SNAT. Requires at least one IP range."

  validation {
    condition     = length(var.private_ip_ranges) > 0
    error_message = "The variable 'private_ip_ranges' must have atleat one IP range item."
  }
}

variable "sku_tier" {
  type        = string
  description = "(Optional) The SKU Tier of the Firewall Policy. Possible values are Standard, Premium. Changing this forces a new Firewall Policy to be created. Default is Standard."
  default     = "Standard"

  validation {
    condition     = can(regex("Standard|Premium", var.sku_tier))
    error_message = "The variable 'sku_tier' must be either Standard (Default), or Premium."
  }
}

variable "managed_identity_type" {
  type        = string
  description = " (Required) Specifies the type of Managed Service Identity that should be configured on this Firewall Policy. Only possible value is UserAssigned."
  default     = "UserAssigned"
  validation {
    condition     = can(regex("UserAssigned$", var.managed_identity_type))
    error_message = "The variable 'managed_identity_type' must be:  UserAssigned."
  }
}

variable "managed_identity_ids" {
  type        = list(string)
  description = "(Optional) Specifies a list of User Assigned Managed Identity IDs to be assigned to this Windows Virtual Machine Scale Set."
  default     = []
}

variable "logs" {
  type = object({
    enabled   = bool   #  (Required) Whether the insights functionality is enabled for this Firewall Policy.
    law_id    = string #  (Required) The ID of the default Log Analytics Workspace that the Firewalls associated with this Firewall Policy will send their logs to, when there is no location matches in the log_analytics_workspace.
    retention = number #  (Optional) The log retention period in days.
    laws = list(object({
      id                = string # (Required) The ID of the Log Analytics Workspace that the Firewalls associated with this Firewall Policy will send their logs to when their locations match the firewall_location.
      firewall_location = string # (Required) The location of the Firewalls, that when matches this Log Analytics Workspace will be used to consume their logs
    }))                          # (Optional) A list of log_analytics_workspace block as defined below.
  })
  description = "Log insights"
  default = {
    enabled   = false
    law_id    = null
    retention = 1
    laws      = []
  }
}

variable "dns" {
  type = object({
    proxy_enabled = bool         # (Optional) Whether to enable DNS proxy on Firewalls attached to this Firewall Policy? Defaults to false.
    servers       = list(string) # (Optional) A list of custom DNS servers' IP addresses.
  })
  description = "DNS"
  default = {
    proxy_enabled = false
    servers       = []
  }
}

variable "threat_allowlist" {
  type = object({
    fqdns        = list(string) # (Optional) A list of FQDNs that will be skipped for threat detection.
    ip_addresses = list(string) # (Optional) A list of IP addresses or CIDR ranges that will be skipped for threat detection.
  })
  default = {
    fqdns        = []
    ip_addresses = []
  }
}

variable "threat_mode" {
  type        = string
  description = "Optional) The operation mode for Threat Intelligence. Possible values are Alert, Deny and Off. Defaults to Alert."
  default     = "Alert"

  validation {
    condition     = can(regex("Alert|Off|Deny", var.threat_mode))
    error_message = "The variable 'threat_mode' must be either Alert (Default), Off or Deny."
  }
}

variable "tags" {
  type        = map(any)
  description = "A mapping of tags to assign to the resource."
  default     = {}
}
