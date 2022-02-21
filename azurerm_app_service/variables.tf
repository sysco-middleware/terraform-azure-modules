variable "enabled" {
  type        = bool
  description = "Is the App Service Enabled?"
  default     = true
}
variable "backup_enabled" {
  type        = bool
  description = "Is this Backup enabled?"
  default     = true
}
variable "fx_version" {
  type        = string
  description = "Web server side version: DOTNETCORE|3.1, PYTHON|3.9, etc"
  default     = "DOTNETCORE|3.1"
}
variable "name" {}
variable "rg_name" {}
variable "app_insights" {
  type = object({
    enabled             = bool
    instrumentation_key = string
    connection_string   = string
  })
  description = "Aplication insights"
  default = {
    enabled             = false
    instrumentation_key = null
    connection_string   = null
  }
}
variable "asp_name" {}
variable "app_settings" {
  type        = map(string)
  description = "Map of App Settings. This will be merged with default app settings"
  default     = {}
}
variable "connection_strings" {
  type = list(object({
    name = string
    type = string
    conn = string
  }))
  description = "A list of connectionstrings"
  default     = []

  validation {
    condition = alltrue([
      for item in var.connection_strings : can(regex("^SQLAzure$|^SQLServer$|^Custom$|^PIHub$|`^DocDb$|^EventHub$|^MySQL$|^NotificationHub$|^PostgreSQL$|^RedisCache$|^ServiceBus$", item.type))
    ])
    error_message = "The variable 'connection_strings' must have valid type: 'SQLAzure', 'SQLServer', 'Custom', .. ."
  }
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
variable "storage_account" {
  type = object({
    enabled      = bool
    name         = string
    type         = string
    share_name   = string
    share_key    = string
    account_name = string
    mount_path   = string # "/var/www/html/assets"
  })
  description = "This mounts the website on a storage account. Note: Will get '503 service unavailable', if the share isn't created"
  default = {
    enabled      = false
    name         = null
    type         = null
    share_name   = null
    share_key    = null
    account_name = null
    mount_path   = null
  }
  validation {
    condition     = can(regex("^AzureFiles$|^AzureBlob$|^AzureFiles$", var.storage_account.type))
    error_message = "Variable 'storage_account' must either be 'Disabled', 'FtpsOnly' or 'AllAllowed'."
  }
}
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
variable "health_check_path" {
  type        = string
  description = "(Optional) The health check path to be pinged by App Service. https://azure.github.io/AppService/2020/08/24/healthcheck-on-app-service.html"
  default     = "/"
}
variable "detailed_error_messages_enabled" {
  type        = bool
  description = "Should Detailed error messages be enabled on this App Service?"
  default     = true
}

variable "failed_request_tracing_enabled" {
  type        = bool
  description = "Should Failed request tracing be enabled on this App Service?"
  default     = true
}

variable "retention_in_days" {
  type        = number
  description = "The number of days to retain http or/and application logs for."
  default     = 8
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

variable "retention_in_mb" {
  type        = number
  description = "The maximum size in megabytes that http log files can use before being removed."
  default     = 100
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
variable "ip_restrictions" {
  type = list(object({
    name                      = string
    action                    = string
    priority                  = number
    ip_address                = string
    virtual_network_subnet_id = string
    service_tag               = string
    headers = list(object({
      x_azure_fdid      = set(string)
      x_fd_health_probe = set(string)
      x_forwarded_for   = set(string)
      x_forwarded_host  = set(string)
    }))
  }))
  description = "The IP Address used for this IP Restriction. One of either ip_address, service_tag or virtual_network_subnet_id must be specified. IP_address should be CIDR or IP-address/32"
  default     = []
}
variable "scm_type" {
  type        = string
  description = "(Optional) The type of Source Control enabled for this App Service. Defaults to None. Possible values are: BitbucketGit, BitbucketHg, CodePlexGit, CodePlexHg, Dropbox, ExternalGit, ExternalHg, GitHub, LocalGit, None, OneDrive, Tfs, VSO, and VSTSRM"
  default     = "None"
}

variable "tags" {
  type        = map(any)
  description = "A mapping of tags to assign to the resource."
  default     = {}
}
