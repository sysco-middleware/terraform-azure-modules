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
    name         = string # (Required) The name of the storage account identifier.
    type         = string # (Required) The type of storage. Possible values are AzureBlob and AzureFiles
    share_name   = string # (Required) The name of the file share (container name, for Blob storage)
    access_key   = string # (Required) The access key for the storage account.
    account_name = string # (Required) The name of the storage account
    mount_path   = string # (Optional) The path to mount the storage within the site's runtime environment. Ex: /var/www/html/assets
  })
  description = "This mounts the website on a storage account. Note: Will get '503 service unavailable', if the share isn't created"
  default = {
    enabled      = false
    name         = null
    type         = "AzureFiles"
    share_name   = null
    access_key   = null
    account_name = null
    mount_path   = null
  }
  validation {
    condition     = can(regex("^AzureFiles$|^AzureBlob$", var.storage_account.type))
    error_message = "Variable 'storage_account.type' must either be 'AzureFiles' or 'AzureBlob'."
  }
}
variable "backup" {
  type = object({
    name                = string # (Required) Specifies the name for this Backup
    enabled             = bool   # (Required) Is this Backup enabled?
    storage_account_url = string
    schedule = object({
      frequency_interval       = string # (Required) Sets how often the backup should be executed.
      frequency_unit           = string # (Optional) Sets the unit of time for how often the backup should be executed. Possible values are Day or Hour.
      keep_at_least_one_backup = bool   # (Optional) Should at least one backup always be kept in the Storage Account by the Retention Policy, regardless of how old it is?
      retention_period_in_days = string # (Optional) Specifies the number of days after which Backups should be deleted.
      start_time               = string # (Optional) Sets when the schedule should start working.
    })
  })
  description = "Backup for the App Service"
  default = {
    name                = "backup"
    enabled             = false
    storage_account_url = null
    schedule = {
      frequency_interval       = 1
      frequency_unit           = "Day"
      keep_at_least_one_backup = false
      retention_period_in_days = 1
      start_time               = null
    }
  }
}

variable "logs" {
  type = object({
    detailed_error_messages = bool # (Optional) Should detailed error messages be enabled.
    failed_request_tracing  = bool # (Optional) Should tracing be enabled for failed requests.
  })
  description = "(Optional) Overall log settings"
  default = {
    detailed_error_messages = false
    failed_request_tracing  = false
  }
}

variable "application_logs" {
  type = object({
    enabled = bool
    azure_blob_storage = object({
      level             = string # (Required) The level at which to log. Possible values include Error, Warning, Information, Verbose and Off. NOTE: this field is not available for http_logs
      sas_url           = string # (Required) The URL to the storage container with a shared access signature token appended.
      retention_in_days = number # (Required) The number of days to retain logs for.
    })
    file_system_level = string # (Optional) Log level for filesystem based logging. Supported values are Error, Information, Verbose, Warning and Off. Defaults to Off.
  })
  description = "Application logs for the App Service"
  default = {
    enabled = false
    azure_blob_storage = {
      level             = "Off"
      sas_url           = null
      retention_in_days = 10
    }
    file_system_level = "Off"
  }
}
variable "http_logs" {
  type = object({
    enabled = bool
    file_system = object({
      retention_in_days = number # (Required) The number of days to retain logs for.
      retention_in_mb   = number # (Required) The maximum size in megabytes that http log files can use before being removed. 
    })
    azure_blob_storage = object({
      sas_url           = string
      retention_in_days = number
    })
  })
  description = "HTTP logs for the App Service"
  default = {
    enabled = false
    file_system = {
      retention_in_days = 1
      retention_in_mb   = 10
    }
    azure_blob_storage = {
      sas_url           = null
      retention_in_days = 10
    }
  }
}
variable "cors" {
  type = object({
    enabled             = bool
    allowed_origins     = list(string) # A list of origins which should be able to make cross-origin calls
    support_credentials = bool         # (Optional) Are credentials supported?
  })
  description = "Cross-Origin Resource Sharing (CORS) allows JavaScript code running in a browser on an external host to interact with your backend"
  default = {
    enabled             = false
    allowed_origins     = ["*"]
    support_credentials = true
  }
}
variable "app_command_line" {
  type        = string
  description = "App service command line"
  default     = null # dotnet myfunc.dll
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
variable "client_cert_mode" {
  type        = string
  description = "(Optional) Mode of client certificates for this App Service. Possible values are Required, Optional and OptionalInteractiveUser. If this parameter is set, client_cert_enabled must be set to true, otherwise this parameter is ignored."
  default     = "OptionalInteractiveUser"
  validation {
    condition     = can(regex("^Required$|^Optional$|^OptionalInteractiveUser$", var.client_cert_mode))
    error_message = "The variable 'client_cert_mode' must have value storage_account_type: Required, Optional or OptionalInteractiveUser."
  }
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
  description = "(Optional) Should Detailed error messages be enabled on this App Service? Default is false."
  default     = false
}
variable "failed_request_tracing_enabled" {
  type        = bool
  description = "(Optional) Should Failed request tracing be enabled on this App Service? Defaults to false."
  default     = false
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
    ip_address                = string # (Optional) The IP Address used for this IP Restriction in CIDR notation.
    virtual_network_subnet_id = string
    service_tag               = string # (Optional) The Service Tag used for this IP Restriction
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
variable "vnet_route_all_enabled" {
  type        = bool
  description = "(Optional) Should all outbound traffic to have Virtual Network Security Groups and User Defined Routes applied? Defaults to false."
  default     = false
}
variable "tags" {
  type        = map(any)
  description = "A mapping of tags to assign to the resource."
  default     = {}
}
