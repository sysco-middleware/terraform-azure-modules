variable "rg_name" {}
variable "kv_name" {}
variable "lock_resource" {
  type        = bool
  description = "Adds lock level CanNotDelete to the resource"
  default     = false
}
variable "sqlserver" {
  type = object({
    name             = string
    login_name       = string # (Required) The name of the server login. Changing this forces a new resource to be created.
    password         = string #  (Required) The password of the server login.
    default_database = string # (Optional) The default database of this server login. Defaults to master. This argument does not apply to Azure SQL Database.
    default_language = string # (Optional) The default language of this server login. Defaults to us_english. This argument does not apply to Azure SQL Database.
  })
  description = "The SQL server"
}
variable "databases" {
  type = list(object({
    database         = string
    username         = string       # Required) The name of the database user. Changing this forces a new resource to be created
    login_name       = string       # (Optional) The login name of the database user. This must refer to an existing SQL Server login name. Conflicts with the password argument. Changing this forces a new resource to be created.
    password         = string       # (Optional) The password of the database user. Conflicts with the login_name argument. Changing this forces a new resource to be created.
    roles            = list(string) # (Optional) List of database roles the user has. Defaults to none
    default_language = string       # (Optional) Specifies the default language for the user. If no default language is specified, the default language for the user will bed the default language of the database. This argument does not apply to Azure SQL Database or if the user is not a contained database user.
    default_schema   = string       # (Optional) Specifies the first schema that will be searched by the server when it resolves the names of objects for this database user. Defaults to dbo.
    kv_secret = object({
      name  = string # Name og the KV secret
      value = string # Database user Connection String
    })
  }))
  description = "A list object of database names"
  default     = []
  sensitive   = true
}
variable "sa_name" {}
variable "sa_type" {
  type        = string
  description = "Specifies the storage account type used to store backups for this database. Changing this forces a new resource to be created."
  default     = "Geo"
  validation {
    condition     = can(regex("Local|Geo|GeoZone|Zone", var.sa_type))
    error_message = "Variable 'sa_type' must be Local, Geo (Default), GeoZone or Zone."
  }
}

variable "sku_name" {
  type        = string
  description = "Specifies the name of the sku used by the database. Only changing this from tier Hyperscale to another tier will force a new resource to be created"
  default     = "S0" # az sql db list-editions -l norwayeast -o table
}

variable "collation" {
  type        = string
  description = "sSpecifies the collation of the database. Changing this forces a new resource to be created"
  default     = "SQL_Latin1_General_CP1_CI_AS"
}

variable "max_size_gb" {
  type        = number
  description = "The max size of the database in gigabytes."
  default     = 4
}

variable "elastic_pool_id" {
  type        = string
  description = "(Optional) Specifies the ID of the elastic pool containing this database."
  default     = null
}

variable "geo_backup_enabled" {
  type        = bool
  description = "A boolean that specifies if the Geo Backup Policy is enabled."
  default     = true
}

variable "tdal_retention_days" {
  type        = number
  description = "Specifies the number of days to keep in the Threat Detection audit logs."
  default     = 7
}

variable "log_retension_days" {
  type        = number
  description = "Specifies the number of days to retain logs for in the storage account."
  default     = 14
}

variable "pit_retention_days" {
  type        = number
  description = "Point In Time Restore configuration. Value has to be between 7 (Default) and 35"
  default     = 7
  validation {
    condition = var.pit_retention_days >= 7 && var.pit_retention_days <= 35
    error_message = "Variable 'pit_retention_days' must be between 7 (Default) and 35." 
  }
}

variable "backup_interval_in_hours" {
  type        = number
  description = "(Optional) The hours between each differential backup. This is only applicable to live databases but not dropped databases. Value has to be 12 or 24. Defaults to 12 hours."
  default     = 12
  validation {
    condition = can(regex("12|24", var.backup_interval_in_hours))
    error_message = "Variable 'backup_interval_in_hours' must be either 12 (Default) or 24." 
  }
}

variable "auditing_enabled" {
  type        = bool
  description = "(Required) Whether to enable the extended auditing policy. Possible values are true and false. Defaults to true."
  default     = true
}

variable "log_monitoring_enabled" {
  type        = bool
  description = "Enable audit events to Azure Monitor? To enable server audit events to Azure Monitor, please enable its main database audit events to Azure Monitor."
  default     = true
}

variable "tdp_enabled" {
  type        = string
  description = "The State of the Policy. Possible values are Enabled, Disabled or New"
  default     = "Enabled"
}

variable "tags" {
  type        = map(any)
  description = "A mapping of tags to assign to the resource."
  default     = {}
}
variable "tenant_id" {}
variable "client_id" {}
variable "client_secret" {}
