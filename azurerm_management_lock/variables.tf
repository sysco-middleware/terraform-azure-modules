variable "name" {}
variable "rg_name" {}
variable "scope" {
  type        = string
  description = "(Required) Specifies the scope at which the Management Lock should be created. Changing this forces a new resource to be created."
}
variable "lock_level" {
  type        = string
  description = "(Required) Specifies the Level to be used for this Lock. Possible values are CanNotDelete and ReadOnly. Changing this forces a new resource to be created."
  validation {
    condition     = contains(["CanNotDelete", "ReadOnly"], var.lock_level)
    error_message = "Variable \"lock_level\" must either be \"CanNotDelete\" or \"ReadOnly\"."
  }
}
variable "notes" {
  type        = string
  description = "(Optional) Specifies some notes about the lock. Maximum of 512 characters. Changing this forces a new resource to be created."
  default     = null
}
