variable "asvnsc_win_apps_wa" {
  type = list(object({
    name    = string
    rg_name = string
  }))
  description = "Enables app_service_virtual_network_swift_connection for App Service"
  default     = []
}

variable "asvnsc_win_apps_fa" {
  type = list(object({
    name    = string
    rg_name = string
  }))
  description = "Enables app_service_virtual_network_swift_connection for Function app"
  default     = []
}

variable "asvnsc_lin_apps_wa" {
  type = list(object({
    name    = string
    rg_name = string
  }))
  description = "Enables app_service_virtual_network_swift_connection for App Service"
  default     = []
}

variable "asvnsc_lin_apps_fa" {
  type = list(object({
    name    = string
    rg_name = string
  }))
  description = "Enables app_service_virtual_network_swift_connection for Function app"
  default     = []
}

variable "asvnsc_snet_name_wa" {
  type        = string
  description = "The name of the Web App Subnet"
  default     = null
}

variable "asvnsc_snet_name_fa" {
  type        = string
  description = "The name of the Function App Subnet"
  default     = null
}

variable "asvnsc_snet_rg_name" {}

variable "asvnsc_snet_vnet_name" {}

variable "mssqlvn_rules" {
  type = list(object({
    sql_name  = string
    rule_name = string
    rg_name   = string
  }))
  description = "Enables azurerm_mssql_virtual_network_rule for SQL Server"
  default     = []
}

variable "mssqlvn_snet_name" {
  type    = string
  default = null
}
variable "mssqlvn_snet_rg_name" {
  type    = string
  default = null
}
variable "mssqlvn_snet_vnet_name" {
  type    = string
  default = null
}
