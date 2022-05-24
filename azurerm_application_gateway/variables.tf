variable "name" {}
variable "rg_name" {}
variable "tier" {
  type        = string
  description = " (Required) The Tier of the SKU to use for this Application Gateway. Possible values are Standard, Standard_v2, WAF and WAF_v2."
  default     = "Standard" # WAF
}
variable "sku" {
  type = string

  default = "Standard_Small" # WAF_Medium
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
variable "snet_name" {}
variable "pipa_name" {}
variable "pipa_rg_name" {}

#variable "cert_file" {

#}
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
variable "ssl_cert_name" {
  type        = string
  description = "(Required) The Name of the SSL certificate that is unique within this Application Gateway and exist in the Key Vault"
}
variable "host_names" {
  type        = list(string)
  description = "List of http_listener host names. Supports wildcard. Example *.domain.com"
  default     = []
}

variable "backend_address_pool" {
  type = list(object({
    name         = string       #  (Required) The name of the Backend Address Pool.
    ip_addresses = list(string) # (Optional) A list of IP Addresses which should be part of the Backend Address Pool.
    fqdns        = list(string) # (Optional) A list of FQDN's which should be part of the Backend Address Pool. 
  }))
  default = []
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
}



variable "tags" {
  type        = map(any)
  description = "A mapping of tags to assign to the resource."
  default     = {}
}
