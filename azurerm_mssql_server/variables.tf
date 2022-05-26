variable "name" {}
variable "lock_resource" {
  type        = bool
  description = "Adds lock level CanNotDelete to the resource"
  default     = false
}
variable "rg_name" {}
variable "sa_name" {}
variable "kv_name" {}
variable "sql_admin_group" {}
variable "law_id" {
  type        = string
  description = "Log Analytics Worspace ID for diagnostc logs"
  default     = null
}
variable "admin_user" {
  type = object({
    name        = string
    value       = string
    description = string
  })
  description = "SQL Server administrator username."
  default = {
    name        = "sql-administrator-username"
    value       = "sqladmin"
    description = "Azure SQL Server administrator username"
  }
}
variable "admin_pass" {
  type = object({
    name        = string
    value       = string
    description = string
  })
  description = "SQL Server administrator password."
  default = {
    name        = "sql-administrator-password"
    value       = null
    description = "Azure SQL Server administrator username"
  }
  validation {
    condition     = var.admin_pass != null
    error_message = "Variable \"admin_pass.value\" must have a valid password."
  }
}
variable "member_admin_ids" {
  type        = list(string)
  description = "The object IDs of the Admins users of the sql_admin_group"
  default     = []
}
variable "member_dev_ids" {
  type        = list(string)
  description = "The object IDs of the Developer users of the sql_admin_group"
  default     = []
}
variable "retention_in_days" {
  type        = number
  description = "Specifies the number of days to retain logs for in the storage account. Default is 90 days."
  default     = 90
}
variable "public_enabled" {
  type        = bool
  description = "Whether public network access is allowed for this server."
  default     = true
}
variable "azureservices_enabled" {
  type        = bool
  description = "Allow Azure services and resources to access this server"
  default     = true
}
variable "firewall_rules" {
  type = list(object({
    name     = string
    start_ip = string
    end_ip   = string
  }))
  default = []
  validation {
    condition = alltrue([
      for item in var.firewall_rules : can(regex("^[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}$", item.start_ip))
    ])
    error_message = "The start_ip and end_ip must be a valid IP address."
  }

}
variable "log_monitoring_enabled" {
  type        = bool
  description = "Enable audit events to Azure Monitor? To enable server audit events to Azure Monitor, please enable its main database audit events to Azure Monitor."
  default     = true
}

variable "sql_version" {
  type        = string
  description = "The version for the new server. Valid values are: 2.0 (for v11 server) and 12.0 (for v12 server)."
  default     = "12.0"
}

variable "minimum_tls_version" {
  type        = string
  description = "The SQL Server version"
  default     = "1.2"
}
variable "enable_rbac_authorization" {
  type        = bool
  description = "Activates RBAC on the resource"
  default     = false
}
variable "rbac_roles" {
  type = list(object({
    role_definition_name = string
    principal_id         = string
  }))
  description = "Role definition name to give access to, ex: SQL DB Contributor. Note: var.enable_rbac_authorization must be true"
  default     = []
}
variable "alert_state" {
  type        = string
  description = "Required) Specifies the state of the policy, whether it is enabled or disabled or a policy has not been applied yet on the specific database server. Allowed values are: Disabled, Enabled."
  default     = "Enabled"
  validation {
    condition     = contains(["Enabled", "Disabled"], var.alert_state)
    error_message = "Variable \"alert_state\" must either be \"Enabled\" or \"Disabled\"."
  }
}
variable "email_admins" {
  type        = bool
  description = " (Optional) Boolean flag which specifies if the alert is sent to the account administrators or not. Defaults to false"
  default     = false
}
variable "email_addresses" {
  type        = list(string)
  description = " (Optional) Specifies an array of e-mail addresses to which the alert is sent."
  default     = []
}
variable "tags" {
  type        = map(any)
  description = "A mapping of tags to assign to the resource."
  default     = {}
}
