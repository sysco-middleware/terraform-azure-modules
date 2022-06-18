terraform {
  required_version = ">= 0.15.0"

  experiments = [module_variable_optional_attrs]
}

variable "name" {}
variable "rg_name" {}
variable "kv_id" {
  type        = string
  description = ""
  default     = null
}
variable "tier" {
  type        = string
  description = "(Required) The Tier of the SKU to use for this Application Gateway. Possible values are Standard, Standard_v2, WAF and WAF_v2."
  default     = "Standard_v2" # WAF
  validation {
    condition     = can(regex("Standard|Standard_v2|WAF|WAF_v2", var.tier))
    error_message = "The variable must either be: Standard (Default), Standard_v2, WAF and WAF_v2."
  }
}

variable "sku" {
  type        = string
  description = "(Required) The Name of the SKU to use for this Application Gateway. Possible values are Standard_Small, Standard_Medium, Standard_Large, Standard_v2, WAF_Medium, WAF_Large, and WAF_v2."
  default     = "Standard_v2" # WAF_Medium
  validation {
    condition     = can(regex("Standard_Small|Standard_Medium|Standard_Large|Standard_v2|WAF_Medium|WAF_Large|WAF_v2", var.sku))
    error_message = "The variable must either be: Standard_Small, Standard_Medium, Standard_Large, Standard_v2 (Default), WAF_Medium, WAF_Large, and WAF_v2."
  }
}

variable "zones" {
  type        = list(string)
  description = "(Optional) Specifies a list of Availability Zones in which this Application Gateway should be located. Changing this forces a new Application Gateway to be created."
  default     = []
}

variable "capacity" {
  type        = number
  description = "(Required) The Capacity of the SKU to use for this Application Gateway. When using a V1 SKU this value must be between 1 and 32, and 1 to 125 for a V2 SKU. This property is optional if autoscale_configuration is set."
  default     = 2
  validation {
    condition     = var.capacity >= 1 && var.capacity <= 125
    error_message = "Variable object 'autoscale' must be: autoscale.min_capacity 0..100, autoscale.max_capacity 2..125,  "
  }
}

variable "autoscale" {
  type = object({
    enabled      = bool
    min_capacity = number # (Required) Minimum capacity for autoscaling. Accepted values are in the range 0 to 100.
    max_capacity = number # (Optional) Maximum capacity for autoscaling. Accepted values are in the range 2 to 125.
  })
  default = {
    enabled      = false
    min_capacity = 1
    max_capacity = 8
  }
  validation {
    condition     = var.autoscale.min_capacity >= 0 && var.autoscale.min_capacity <= 100 && var.autoscale.max_capacity >= 2 && var.autoscale.max_capacity <= 125
    error_message = "Variable object 'autoscale' must be: autoscale.min_capacity 0..100, autoscale.max_capacity 2..125,  "
  }
}

variable "http2_enabled" {
  type        = bool
  description = "(Optional) Is HTTP2 enabled on the application gateway resource? Defaults to true."
  default     = true
}

variable "rewrite_rule_sets" {
  type = list(object({
    name = string
    rewrite_rules = list(object({
      name     = string # (Required) Unique name of the rewrite rule block
      sequence = string # (Required) Rule sequence of the rewrite rule that determines the order of execution in a set.
      conditions = list(object({
        variable    = string # (Required) The variable of the condition. https://docs.microsoft.com/azure/application-gateway/rewrite-http-headers#server-variables
        pattern     = string # (Required) The pattern, either fixed string or regular expression, that evaluates the truthfulness of the condition.
        ignore_case = bool   # (Optional) Perform a case in-sensitive comparison. Defaults to false
        negate      = bool   # (Optional) Negate the result of the condition evaluation. Defaults to false
      }))
      request_headers = list(object({
        name  = string # (Required) Header name of the header configuration.
        value = string # (Required) Header value of the header configuration. To delete a request header set this property to an empty string.
      }))
      response_headers = list(object({
        name  = string # (Required) Header name of the header configuration.
        value = string # (Required) Header value of the header configuration. To delete a response header set this property to an empty string.
      }))
      url = list(object({
        path         = string # (Optional) The URL path to rewrite.
        query_string = string # (Optional) The query string to rewrite.
        reroute      = string # (Optional) Whether the URL path map should be reevaluated after this rewrite has been applied. https://docs.microsoft.com/azure/application-gateway/rewrite-http-headers-url#rewrite-configuration
      }))
    }))
  }))
  description = "Rewrite rule sets. https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway"
  default     = []
}

variable "fw_policy_id" {
  type        = string
  description = "(Optional) The ID of the Web Application Firewall Policy."
  default     = null
}

variable "fips_enabled" {
  type        = string
  description = "(Optional) Is FIPS enabled on the Application Gateway?"
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

variable "managed_identity_ids" {
  type        = list(string)
  description = "(Optional) Specifies a list with a single user managed identity id to be assigned to the Application Gateway."
  default     = []
}

variable "gateway_ips" {
  type = list(object({
    name    = string # (Required) The Name of this Gateway IP Configuration.
    snet_id = string #  (Required) The ID of the Subnet which the Application Gateway should be connected to.
  }))
  description = ""
  validation {
    condition     = length(var.gateway_ips) > 0
    error_message = "The list variable 'gateway_ips' most be at least one object."
  }
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

variable "frontend_ips" {
  type = list(object({
    name             = string           # (Required) The name of the Frontend IP Configuration.
    snet_id          = optional(string) # (Optional) The ID of the Subnet.
    private_ip       = optional(string) # (Optional) The Private IP Address to use for the Application Gateway. Must be in the Subnet range ==> cidrhost("10.100.0.0/16", 0) => gives the first
    pipa_id          = string           # (Required) The ID of a Public IP Address which the Application Gateway should use. The allocation method for the Public IP Address depends on the sku of this Application Gateway. Please refer to the Azure documentation for public IP addresses for details.
    pripa_allocation = optional(string) # (Optional) The Allocation Method for the Private IP Address. Possible values are Dynamic and Static.
    private_link_cn  = optional(string) # (Optional) The name of the private link configuration to use for this frontend IP configuration.
  }))
  description = ""
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
    name                  = string           # (Required) The name of the Backend Address Pool.
    cookie_based_affinity = string           # (Required) Is Cookie-Based Affinity enabled? Possible values are Enabled and Disabled.
    affinity_cookie_name  = optional(string) # (Optional) The name of the affinity cookie.
    path                  = string           # (Optional) The Path which should be used as a prefix for all HTTP requests.
    port                  = number           # (Required) The port which should be used for this Backend HTTP Settings Collection.
    probe_name            = optional(string) # (Optional) The name of an associated HTTP Probe.
    protocol              = string           # (Required) The Protocol which should be used. Possible values are Http and Https.
    request_timeout       = number           # (Required) The request timeout in seconds, which must be between 1 and 86400 seconds.
    host_name             = optional(string) # (Optional) Host header to be sent to the backend servers. Cannot be set if pick_host_name_from_backend_address is set to true.
    phnfba                = string           # (Optional) pick_host_name_from_backend_address. Whether host header should be picked from the host name of the backend server. Defaults to false.
    auth_certificates = optional(list(object({
      name = string # (Required) The Name of the Authentication Certificate to use.
    })))
    trcns = optional(list(string)) #  (Optional) A list of trusted_root_certificate names.
    fqdns = optional(list(string)) # (Optional) A list of FQDN's which should be part of the Backend Address Pool. 
    connection_draining = optional(object({
      enabled     = bool   # (Required) If connection draining is enabled or not.
      timeout_sec = number # (Required) The number of seconds connection draining is active. Acceptable values are from 1 second to 3600 seconds.
    }))
  }))
  default = []
  #validation {
  #  condition     = length(var.backend_http_settings) > 0
  #  error_message = "The list variable 'backend_http_settings' most be at least one object."
  #}
}

variable "http_listeners" {
  type = list(object({
    name             = string                 # (Required) The Name of the HTTP Listener.
    fe_ip_conf_name  = string                 # (Required) The Name of the Frontend IP Configuration used for this HTTP Listener.
    fe_port_name     = string                 # (Required) The Name of the Frontend Port use for this HTTP Listener.
    host_name        = optional(string)       # (Optional) The host_names and host_name are mutually exclusive and cannot both be set. The Hostname which should be used for this HTTP Listener. Setting this value changes Listener Type to 'Multi site'.
    host_names       = optional(list(string)) # (Optional) The host_names and host_name are mutually exclusive and cannot both be set. A list of Hostname(s) should be used for this HTTP Listener. It allows special wildcard characters.
    protocol         = string                 # (Required) The Protocol to use for this HTTP Listener. Possible values are Http and Https. Https requires Ssl Certificate must be specified
    require_sni      = optional(bool)         # (Optional) Should Server Name Indication be Required? Defaults to false.
    ssl_cert_name    = optional(string)       # (Optional) The name of the associated SSL Certificate which should be used for this HTTP Listener.
    ssl_profile_name = optional(string)       # (Optional) The name of the associated SSL Profile which should be used for this HTTP Listener.
    fw_policy_id     = optional(string)       # (Optional) The ID of the Web Application Firewall Policy which should be used for this HTTP Listener.

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

variable "url_path_maps" {
  type = list(object({
    name                 = string           # (Required) The Name of the URL Path Map.
    def_be_address_pool  = optional(string) # (Optional) The Name of the Default Backend Address Pool which should be used for this URL Path Map. Cannot be set if default_redirect_configuration_name is set.
    def_be_setting       = optional(string) # (Optional) The Name of the Default Backend HTTP Settings Collection which should be used for this URL Path Map. Cannot be set if default_redirect_configuration_name is set.
    def_redirect_conf    = optional(string) # (Optional) The Name of the Default Redirect Configuration which should be used for this URL Path Map. Cannot be set if either default_backend_address_pool_name or default_backend_http_settings_name is set.
    def_rewrite_rule_set = optional(string) # (Optional) The Name of the Default Rewrite Rule Set which should be used for this URL Path Map. Only valid for v2 SKUs.
    path_rules = list(object({
      name             = string           # (Required) The Name of the Path Rule.
      paths            = list(string)     # (Required) A list of Paths used in this Path Rule.
      be_address_pool  = string           # (Optional/Required) The Name of the Backend Address Pool to use for this Path Rule. Cannot be set if redirect_configuration_name is set.
      be_setting       = string           # (Optional/Required) The Name of the Backend HTTP Settings Collection to use for this Path Rule. Cannot be set if redirect_configuration_name is set.
      redirect_conf    = optional(string) # (Optional) The Name of a Redirect Configuration to use for this Path Rule. Cannot be set if backend_address_pool_name or backend_http_settings_name is set.
      rewrite_rule_set = optional(string) # (Optional) The Name of the Rewrite Rule Set which should be used for this URL Path Map. Only valid for v2 SKUs.
      fw_policy_id     = optional(string) # (Optional) The ID of the Web Application Firewall Policy which should be used as a HTTP Listener.
    }))

  }))
  description = "url_path_maps must be defined if request_routing_rules.rule_type is PathBasedRouting."
  default     = []
}

variable "request_routing_rules" {
  type = list(object({
    name              = string           # (Required) The Name of this Request Routing Rule.
    rule_type         = string           # (Required) The Type of Routing that should be used for this Rule. Possible values are Basic and PathBasedRouting.
    listener_name     = string           # (Required) The Name of the HTTP Listener which should be used for this Routing Rule.
    be_address_pool   = optional(string) # (Optional/Required) The Name of the Backend Address Pool which should be used for this Routing Rule. Cannot be set if redirect_configuration_name is set.
    be_setting        = optional(string) # (Optional/Required) The Name of the Backend HTTP Settings Collection which should be used for this Routing Rule. Cannot be set if redirect_configuration_name is set.
    redirect_conf     = optional(string) # (Optional) The Name of the Redirect Configuration which should be used for this Routing Rule. Cannot be set if either backend_address_pool_name or backend_http_settings_name is set.
    rewrite_rule_set  = optional(string) # (Optional) The Name of the Rewrite Rule Set which should be used for this Routing Rule. Only valid for v2 SKUs.
    url_path_map_name = optional(string) # (Optional/Required) The Name of the URL Path Map which should be associated with this Routing Rule. Required if rule_type is PathBasedRouting.
    priority          = number           # (Required) Rule evaluation order can be dictated by specifying an integer value from 1 to 20000 with 1 being the highest priority and 20000 being the lowest priority.
  }))
  description = ""
  validation {
    condition     = length(var.request_routing_rules) > 0
    error_message = "The list variable 'request_routing_rules' most be at least one object."
  }
}

variable "private_links" {
  type = list(object({
    name = string # (Required) The name of the private link configuration.
    ip_configurations = list(object({
      name            = string           # (Required) The name of the IP configuration.
      snet_id         = string           # (Required) The ID of the subnet the private link configuration should connect to.
      pipa_allocation = string           # (Required) The allocation method used for the Private IP Address. Possible values are Dynamic and Static.
      primary         = bool             # (Required) Is this the Primary IP Configuration?
      pipa            = optional(string) # (Optional) The Static IP Address which should be used.
    }))
  }))
  description = ""
  default     = []
}

variable "probes" {
  type = list(object({
    name                = string           # (Required) The Name of the Probe.
    host                = optional(string) # (Optional) The Hostname used for this Probe. If the Application Gateway is configured for a single site, by default the Host name should be specified as ‘127.0.0.1’, unless otherwise configured in custom probe. Cannot be set if pick_host_name_from_backend_http_settings is set to true.
    protocol            = string           # (Required) The Protocol used for this Probe. Possible values are Http and Https.
    path                = string           # (Required) The Path used for this Probe.
    port                = optional(number) # (Optional) Custom port which will be used for probing the backend servers. The valid value ranges from 1 to 65535. In case not set, port from HTTP settings will be used. This property is valid for Standard_v2 and WAF_v2 only.
    interval            = number           # (Required) The Interval between two consecutive probes in seconds. Possible values range from 1 second to a maximum of 86,400 seconds.
    timeout             = number           # (Required) The Timeout used for this Probe, which indicates when a probe becomes unhealthy. Possible values range from 1 second to a maximum of 86,400 seconds.
    unhealthy_threshold = optional(number) # (Optional) Whether the host header should be picked from the backend HTTP settings. Defaults to false.
    min_servers         = optional(number) # (Optional) The minimum number of servers that are always marked as healthy. Defaults to 0.
    phnfbts             = optional(bool)   # (Optional) Whether the host header should be picked from the backend HTTP settings. Defaults to false.
    match = optional(object({
      status_code = list(string) # (Required) A list of allowed status codes for this Health Probe.
      body        = string       # (Required) A snippet from the Response Body which must be present in the Response.
    }))
  }))
  description = ""
  default     = []
}

variable "ssl_policy" {
  type = object({
    name            = string       # (Required) The name of the Frontend Port.
    type            = number       # (Required) The port used for this Frontend Port.
    cipher_suites   = list(string) # (Optional) A List of accepted cipher suites. Possible values are:
    disabled_tls    = list(string) # (Optional) A list of SSL Protocols which should be disabled on this Application Gateway. Possible values are TLSv1_0, TLSv1_1 and TLSv1_2
    min_tls_version = string       # (Optional) The minimal TLS version. Possible values are TLSv1_0, TLSv1_1 and TLSv1_2.
  })
  description = ""
  default = {
    name            = null
    type            = null
    disabled_tls    = ["TLSv1_0", "TLSv1_1"]
    min_tls_version = "TLSv1_2"
    cipher_suites   = ["TLS_RSA_WITH_AES_128_GCM_SHA256", "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384", "TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA", "TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384", "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384", "TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA", "TLS_RSA_WITH_AES_256_GCM_SHA384", "TLS_RSA_WITH_AES_256_CBC_SHA256", "TLS_RSA_WITH_AES_256_CBC_SHA"]
  }
}

variable "ssl_certificates" {
  type = list(object({
    name         = string           # (Required) The Name of the SSL certificate that is unique within this Application Gateway
    data         = optional(string) # (Optional) PFX certificate. Required if key_vault_secret_id is not set.
    password     = optional(string) # (Optional) Password for the pfx file specified in data. Required if data is set.
    kv_secret_id = optional(string) # (Optional) Secret Id of (base-64 encoded unencrypted pfx) Secret or Certificate object stored in Azure KeyVault. You need to enable soft delete for keyvault to use this feature. Required if data is not set
  }))
  description = "(Optional) One or more ssl_certificate"
  default = []
  #sensitive = true # BUG! Can't defined sensitive. Causes for_each in resources to fail
}

variable "waf" {
  type = object({
    firewall_mode        = string           # (Required) The Web Application Firewall Mode. Possible values are Detection and Prevention.
    rule_set_version     = string           # (Required) The Version of the Rule Set used for this Web Application Firewall. Possible values are 2.2.9, 3.0, 3.1, and 3.2.
    file_upload_limit_mb = optional(number) # (Optional) The File Upload Limit in MB. Accepted values are in the range 1MB to 750MB for the WAF_v2 SKU, and 1MB to 500MB for all other SKUs. Defaults to 100MB.
    request_body_check   = optional(bool)   # (Optional) Is Request Body Inspection enabled? Defaults to true

    disabled_rule_group = list(object({
      name  = string
      rules = list(string)
    }))

    exclusion = list(object({
      match_variable          = string           # (Required) Match variable of the exclusion rule to exclude header, cookie or GET arguments. Possible values are RequestHeaderNames, RequestArgNames and RequestCookieNames
      selector_match_operator = optional(string) # (Optional) Operator which will be used to search in the variable content. Possible values are Equals, StartsWith, EndsWith, Contains. If empty will exclude all traffic on this match_variable
      selector                = optional(string) # (Optional) String value which will be used for the filter operation. If empty will exclude all traffic on this match_variable
    }))
  })
  description = "Web Application Firewall configuration. This is applied if tier is using WAF or WAF_2. Defaults: firewall_mode=Detection, rule_set_version=3.1."
  default = {
    firewall_mode        = "Detection"
    rule_set_version     = "3.1"
    disabled_rule_group  = []
    file_upload_limit_mb = 100
    request_body_check   = true
    exclusion            = []
  }
  validation {
    condition     = can(regex("Detection|Prevention", var.waf.firewall_mode)) && can(regex("2.2.9|3.0|3.1|3.2", var.waf.rule_set_version)) && var.waf.file_upload_limit_mb > 0 && var.waf.file_upload_limit_mb <= 750
    error_message = "Variable 'waf' must have property firewall_mode:Detection|Prevention and rule_set_version:2.2.9|3.0|3.1|3.2 and file_upload_limit_mb:1-750."
  }
}

variable "custom_errors" {
  type = list(object({
    status_code = string # (Required) Status code of the application gateway customer error. Possible values are HttpStatus403 and HttpStatus502
    page_url    = string # (Required) Error page URL of the application gateway customer error.
  }))
  description = ""
  default     = []
}

variable "tags" {
  type        = map(any)
  description = "A mapping of tags to assign to the resource."
  default     = {}
}
