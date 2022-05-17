variable "name" {}
variable "rg_name" {}
variable "target_resource_ids" {
  type        = list(string)
  description = "(Required) The ID of an existing Resource on which to configure Diagnostic Settings. Changing this forces a new resource to be created."
  default     = []
}

variable "law_rg_name" {}
variable "law_name" {}
variable "law_dst_type" {
  type        = string
  description = "(Optional) When set to 'Dedicated' logs sent to a Log Analytics workspace will go into resource specific tables, instead of the legacy AzureDiagnostics table."
  default     = "Dedicated"
}

variable "log" {
  type = object({
    category                 = string
    enabled                  = bool
    retention_policy_enabled = bool
    retention_policy_days    = number
  })
  description = "ategory is the granularity at which you can enable or disable logs on a particular resource. The properties that appear within the properties blob of an event are the same within a particular log category and resource type. Typical log categories are Audit, Operational, Execution, and Request."
  default = {
    category                 = "Audit"
    enabled                  = true
    retention_policy_days    = 30
    retention_policy_enabled = false
  }
}

variable "metric" {
  type = object({
    category                 = string
    enabled                  = bool
    retention_policy_enabled = bool
    retention_policy_days    = number
  })
  default = {
    category                 = "AllMetrics"
    enabled                  = true
    retention_policy_days    = 30
    retention_policy_enabled = false
  }
}
