variable "name" {}
variable "rg_name" {}

variable "lock_resource" {
  type        = bool
  description = "Adds lock level CanNotDelete to the resource"
  default     = false
}

variable "sku" {
  type        = string
  description = "(Required) Defines which tier to use. Options are Basic, Standard or Premium. Changing this forces a new resource to be created."
  default     = "Standard"
  validation {
    condition     = can(regex("Basic|Standard|Premium", var.sku))
    error_message = "Variable 'sku' must either be Basic, Standard (Default) or Premium."
  }
}
variable "capacity" {
  type        = number
  description = "(Optional) Specifies the capacity. When sku is Premium, capacity can be 1, 2, 4, 8 or 16. When sku is Basic or Standard, capacity can be 0 only."
  default     = 0
}
variable "topics" {
  type = list(object({
    name = string
    subscriptions = list(object({
      name      = string
      max_count = number
    }))
  }))
  description = "A list of Service bus topics"
  default     = []
}
variable "queues" {
  type = list(object({
    name           = string
    lock_duration  = string # (Optional) The ISO 8601 timespan duration of a peek-lock; that is, the amount of time that the message is locked for other receivers. Maximum value is 5 minutes. Defaults to 1 minute (PT1M).
    max_size_in_mb = number # (Optional) Integer value which controls the size of memory allocated for the queue. For supported values see the "Queue or topic size" section of Service Bus Quotas. Defaults to 1024
  }))
  description = "A list of Service bus queues"
  default     = []
}

variable "zone_redundant" {
  type        = string
  description = "(Optional) Whether or not this resource is zone redundant. sku needs to be Premium. Defaults to false"
  default     = false
}

variable "managed_identity_type" {
  type        = string
  description = "(Optional) The type of Managed Identity which should be assigned to the Linux Virtual Machine Scale Set. Possible values are `SystemAssigned`, `UserAssigned` and `SystemAssigned, UserAssigned`"
  default     = null
  validation {
    condition     = can(regex("^SystemAssigned$|^UserAssigned$|^SystemAssigned, UserAssigned$", var.managed_identity_type))
    error_message = "The variable 'managed_identity_type' must be: SystemAssigned, or UserAssigned or `SystemAssigned, UserAssigned`."
  }
}

variable "managed_identity_ids" {
  type        = list(string)
  description = "(Optional) Specifies a list of User Assigned Managed Identity IDs to be assigned to this Windows Virtual Machine Scale Set."
  default     = []
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
  description = "Role definition name to give access to, ex: Azure Service Bus Data Owner. Note: var.enable_rbac_authorization must be true"
  default     = []
}
variable "local_auth_enabled" {
  type        = string
  description = "(Optional) Whether or not SAS authentication is enabled for the Service Bus namespace. Defaults to true"
  default     = true
}
variable "tags" {
  type        = map(any)
  description = "A mapping of tags to assign to the resource."
  default     = {}
}
