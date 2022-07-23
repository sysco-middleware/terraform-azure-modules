variable "name" {}
variable "rg_name" {}
variable "location" {
  type        = string
  description = "The location/region where the virtual network is created. Changing this forces a new resource to be created. Uses resource group location by default"
  default     = null
}

variable "disable_vpn_encryption" {
  type        = bool
  description = "(Optional) Boolean flag to specify whether VPN encryption is disabled. Defaults to false."
  default     = false
}

variable "type" {
  type        = string
  description = "(Optional) Specifies the Virtual WAN type. Possible Values include: Basic and Standard. Defaults to Standard."
  default     = "Standard"
  validation {
    condition     = can(regex("Basic|Standard", var.type))
    error_message = "Variable 'type' must either be 'Basic' or 'Standard' (Default)."
  }
}

variable "allow_branch_to_branch_traffic" {
  type        = bool
  description = "(Optional) Boolean flag to specify whether branch to branch traffic is allowed. Defaults to true."
  default     = true
}

variable "o365_category" {
  type        = string
  description = "(Optional) Specifies the Office365 local breakout category. Possible values include: Optimize, OptimizeAndAllow, All, None. Defaults to None."
  default     = "None"
  validation {
    condition     = can(regex("Optimize|OptimizeAndAllow|All|None", var.type))
    error_message = "Variable 'type' must either be Optimize, OptimizeAndAllow, All, None (Default)."
  }
}

variable "tags" {
  type        = map(any)
  description = "A mapping of tags to assign to the resource."
  default     = {}
}