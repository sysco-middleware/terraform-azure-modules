variable "name" {}
variable "rg_name" {}

variable "tier" {
  type        = string
  description = "(Required) The Tier of the SKU to use for this Application Gateway. Possible values are Standard, Standard_v2, WAF and WAF_v2."
  default     = "Standard" # WAF
  validation {
    condition     = can(regex("Standard_Small|Standard_Medium|Standard_Large|Standard_v2|WAF_Medium|WAF_Large|WAF_v2", var.tier))
    error_message = "The variable must either be: Standard (Default), Standard_v2, WAF and WAF_v2."
  }
}

variable "sku" {
  type        = string
  description = "(Required) The Name of the SKU to use for this Application Gateway. Possible values are Standard_Small, Standard_Medium, Standard_Large, Standard_v2, WAF_Medium, WAF_Large, and WAF_v2."
  default     = "Standard_Small" # WAF_Medium
  validation {
    condition     = can(regex("Standard_Small|Standard_Medium|Standard_Large|Standard_v2|WAF_Medium|WAF_Large|WAF_v2", var.sku))
    error_message = "The variable must either be: Standard_Small (Default), Standard_Medium, Standard_Large, Standard_v2, WAF_Medium, WAF_Large, and WAF_v2."
  }
}

variable "capacity" {
  type        = number
  description = "(Required) The Capacity of the SKU to use for this Application Gateway. When using a V1 SKU this value must be between 1 and 32, and 1 to 125 for a V2 SKU. This property is optional if autoscale_configuration is set."
  default     = 2
}

variable "max_capacity" {
  type        = number
  description = "(Optional) Maximum capacity for autoscaling. Accepted values are in the range 2 to 125."
  default     = 2
}
variable "min_capacity" {
  type        = number
  description = "(Required) Minimum capacity for autoscaling. Accepted values are in the range 0 to 100."
  default     = 1
}
variable "rewrite_rules" {
  type = list(object({
    name          = string
    rule_sequence = string
    condition = list(object({
      variable    = string
      pattern     = string
      ignore_case = bool
      negate      = bool
    }))
    request_header_configuration = list(object({
      header_name  = string
      header_value = string
    }))
    response_header_configuration = list(object({
      header_name  = string
      header_value = string
    }))
    url = list(object({
      path         = string
      query_string = string
      reroute      = string
    }))
  }))
  description = "Rewrite rule sequence. https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway"
  default     = []
}
variable "vnet_name" {}
variable "vnet_rg_name" {}
variable "pipa_id" {}
variable "fw_policy_id" {
  type        = string
  description = "(Optional) The ID of the Web Application Firewall Policy."
  default     = null
}
variable "fips_enabled" {
  type        = string
  description = " (Optional) Is FIPS enabled on the Application Gateway?"
  default     = false
}

variable "managed_identity_type" {
  type        = string
  description = "(Optional) The type of Managed Identity which should be assigned to the Linux Virtual Machine Scale Set. Possible values are `SystemAssigned`, `UserAssigned` and `SystemAssigned, UserAssigned`"
  default     = "UserAssigned"
  validation {
    condition     = can(regex("UserAssigned", var.managed_identity_type))
    error_message = "The variable 'managed_identity_type' must be: UserAssigned."
  }
}

variable "identity_ids" {
  type        = list(string)
  description = "(Required) Specifies a list with a single user managed identity id to be assigned to the Application Gateway."
  default     = []
}

variable "kv_secret_id" {
  type        = string
  description = " (Optional) Secret Id of (base-64 encoded unencrypted pfx) Secret or Certificate object stored in Azure KeyVault. You need to enable soft delete for keyvault to use this feature. Required if data is not set."
  # For TLS termination with Key Vault certificates to work properly existing user-assigned managed identity, 
  # which Application Gateway uses to retrieve certificates from Key Vault, should be defined via identity block. 
  # Additionally, access policies in the Key Vault to allow the identity to be granted get access to the secret should be defined.
}

variable "frontend_ip_configuration" {
  type = list(object({
    name            = string # (Required) The name of the Frontend IP Configuration.
    snet_id         = string # (Optional) The ID of the Subnet.
    private_ip      = string # (Optional) The Private IP Address to use for the Application Gateway.
    pipa_id         = string # (Optional) The ID of a Public IP Address which the Application Gateway should use. The allocation method for the Public IP Address depends on the sku of this Application Gateway. Please refer to the Azure documentation for public IP addresses for details.
    pipa_alocation  = string # (Optional) The Allocation Method for the Private IP Address. Possible values are Dynamic and Static.
    private_link_cn = string # (Optional) The name of the private link configuration to use for this frontend IP configuration.
  }))
  description = ""
}

variable "frontend_ports" {
  type = list(object({
    name = string # (Required) The name of the Frontend Port.
    port = number # (Required) The port used for this Frontend Port.
  }))
  description = ""
  validation {
    condition     = length(var.frontend_ports) > 0
    error_message = "The list variable 'frontend_ports' most be at least one object."
  }
}

variable "gateway_ip_configurations" {
  type = list(object({
    name    = string # (Required) The Name of this Gateway IP Configuration.
    snet_id = string #  (Required) The ID of the Subnet which the Application Gateway should be connected to.
  }))
  description = ""
  validation {
    condition     = length(var.gateway_ip_configurations) > 0
    error_message = "The list variable 'gateway_ip_configuration' most be at least one object."
  }
}

variable "private_link_configurations" {
  type = list(object({
    name = string # (Required) The name of the private link configuration.
    ip_configurations = list(object({
      name            = string # (Required) The name of the IP configuration.
      snet_id         = string # (Required) The ID of the subnet the private link configuration should connect to.
      pipa_allocation = string # (Required) The allocation method used for the Private IP Address. Possible values are Dynamic and Static.
      primary         = bool   # (Required) Is this the Primary IP Configuration?
      pipa            = string # (Optional) The Static IP Address which should be used.
    }))
  }))
  description = ""
  default     = []
}

variable "backend_address_pools" {
  type = list(object({
    name         = string       # (Required) The name of the Backend Address Pool.
    ip_addresses = list(string) # (Optional) A list of IP Addresses which should be part of the Backend Address Pool.
    fqdns        = list(string) # (Optional) A list of FQDN's which should be part of the Backend Address Pool. 
  }))
  validation {
    condition     = length(var.backend_address_pools) > 0
    error_message = "The list variable 'backend_address_pools' most be at least one object."
  }
}

variable "backend_http_settings" {
  type = list(object({
    name                  = string #  (Required) The name of the Backend Address Pool.
    cookie_based_affinity = string # (Required) Is Cookie-Based Affinity enabled? Possible values are Enabled and Disabled.
    affinity_cookie_name  = string # (Optional) The name of the affinity cookie.
    path                  = string # (Optional) The Path which should be used as a prefix for all HTTP requests.
    port                  = number # (Required) The port which should be used for this Backend HTTP Settings Collection.
    probe_name            = string #  (Optional) The name of an associated HTTP Probe.
    protocol              = string #  (Required) The Protocol which should be used. Possible values are Http and Https.
    request_timeout       = number # (Required) The request timeout in seconds, which must be between 1 and 86400 seconds.
    host_name             = string # (Optional) Host header to be sent to the backend servers. Cannot be set if pick_host_name_from_backend_address is set to true.
    phnfba                = string #  (Optional) pick_host_name_from_backend_address. Whether host header should be picked from the host name of the backend server. Defaults to false.
    auth_certificate = list(object({
      name = string # (Required) The Name of the Authentication Certificate to use.
      data = string # (Required) The contents of the Authentication Certificate which should be used.
    }))
    fqdns = list(string) # (Optional) A list of FQDN's which should be part of the Backend Address Pool. 
  }))
  validation {
    condition     = length(var.backend_http_settings) > 0
    error_message = "The list variable 'backend_http_settings' most be at least one object."
  }
}

variable "http_listeners" {
  type = list(object({
    name             = string       # (Required) The Name of the HTTP Listener.
    fip_conf_name    = string       # (Required) The Name of the Frontend IP Configuration used for this HTTP Listener.
    fip_port_name    = string       # (Required) The Name of the Frontend Port use for this HTTP Listener.
    host_name        = string       # ((Optional) The Hostname which should be used for this HTTP Listener. Setting this value changes Listener Type to 'Multi site'.
    host_names       = list(string) #  (Optional) A list of Hostname(s) should be used for this HTTP Listener. It allows special wildcard characters.
    protocol         = string       # (Required) The Protocol to use for this HTTP Listener. Possible values are Http and Https.
    ssl_cert_name    = string       #  (Optional) The name of the associated SSL Certificate which should be used for this HTTP Listener.
    ssl_profile_name = string       #  (Optional) The name of the associated SSL Profile which should be used for this HTTP Listener.
    fw_policy_id     = string       # (Optional) The ID of the Web Application Firewall Policy which should be used for this HTTP Listener.

    custom_errors = list(object({
      status_code = string # (Required) Status code of the application gateway customer error. Possible values are HttpStatus403 and HttpStatus502
      page_url    = string # (Required) Error page URL of the application gateway customer error.
    }))
  }))
  description = ""
  validation {
    condition     = length(var.http_listeners) > 0
    error_message = "The list variable 'http_listeners' most be at least one object."
  }
}

variable "tags" {
  type        = map(any)
  description = "A mapping of tags to assign to the resource."
  default     = {}
}
