variable "enabled" {
  type        = bool
  description = "Is the App Service Enabled?"
  default     = true
}
variable "fx_version" {
  type        = string
  description = "Web server side version: DOTNETCORE|3.1, PYTHON|3.9, etc"
  default     = "DOTNETCORE|3.1"
}
variable "name" {}
variable "rg_name" {}
variable "asp_name" {}

variable "app_settings" {
  type        = map(string)
  description = "Map of App Settings. This will be merged with default app settings"
  default     = {}
}

variable "auth_settings" {
  type = list(object({
    enabled  = bool
    provider = string
    active_directory = object({
      client_id     = string
      client_secret = string
      audiences     = list(string)
    })
  }))
  description = "Authentication Settings"
  default     = []
}

/*
variable "vnet_enabled" {
  type    = bool
  default = false
}
variable "vnet_rg_name" {}
variable "vnet_name" {}
variable "snet_name" {}
*/
variable "client_affinity_enabled" {
  type        = bool
  description = "Should the App Service send session affinity cookies, which route client requests in the same session to the same instance? Disable for performance"
  default     = false
}
variable "client_cert_enabled" {
  type        = bool
  description = "Does the App Service require client certificates for incoming requests? "
  default     = false
}
variable "https_only" {
  type        = bool
  description = "Can the App Service only be accessed via HTTPS?"
  default     = true
}
variable "ftps_state" {
  type        = string
  description = "(Optional) State of FTP / FTPS service for this App Service. Possible values include: AllAllowed, FtpsOnly and Disabled. AppService log requires this to be activated."
  default     = "FtpsOnly"
  validation {
    condition     = contains(["Disabled", "FtpsOnly", "AllAllowed"], var.ftps_state)
    error_message = "Variable \"ftps_state\" must either be \"Disabled\", \"FtpsOnly\" or \"AllAllowed\"."
  }
}
variable "app_kind" {
  type        = string
  description = "The App Service operating system type: Windows of Linux"
  default     = "windows"
  validation {
    condition     = contains(["windows", "linux"], var.app_kind)
    error_message = "Variable \"app_kind\" must either be \"windows\" or \"linux\"."
  }
}
variable "use_32_bit_worker_process" {
  type        = bool
  description = "(Optional) Should the Function App run in 32 bit mode, rather than 64 bit mode?. When using an App Service Plan in the Free or Shared Tiers use_32_bit_worker_process must be set to true."
  default     = false
}
variable "tags" {
  type        = map(any)
  description = "A mapping of tags to assign to the resource."
  default     = {}
}
