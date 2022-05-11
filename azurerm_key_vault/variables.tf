variable "tenant_id" {}
variable "name" {}
variable "lock_resource" {
  type        = bool
  description = "Adds lock level CanNotDelete to the resource"
  default     = false
}
variable "rg_name" {}
variable "sku_name" {
  type        = string
  description = ""
  default     = ""
}
variable "soft_delete_retention_days" {
  type        = number
  description = "The number of days (7-90) that items should be retained for once soft-deleted. Can't changes this after deploy"
  default     = 14
}
variable "purge_protection_enabled" {
  type        = bool
  description = "CAUSES PROBLEMS IN TERRAFORM!! (Optional) Is Purge Protection enabled for this Key Vault? Defaults to false. Once Purge Protection is enabled, this option cannot be disabled."
  default     = null
}
variable "enable_rbac_authorization" {
  type        = bool
  description = "Activates RBAC on the resource"
  default     = false
}
variable "object_ids" {
  type        = list(string)
  description = "The object ids for Access Policies"
  default     = []
}
variable "rbac_roles" {
  type = list(object({
    role_definition_name = string
    principal_id         = string
  }))
  description = "Role definition name to give access to, ex: Key Vault Administrator. Note: var.enable_rbac_authorization must be true"
  default     = []
}
variable "recover_keyvault" {
  type        = bool
  description = "Tries to Recover Keyvault is previously deleted within soft_delete_retention_days"
  default     = false
}
variable "secrets" {
  type = list(object({
    name         = string
    value        = string
    content_type = string
  }))
  description = "A list of Key Vault secrets"
  default     = []
}
variable "keys" {
  type = list(object({
    name     = string
    key_type = string       # RSA
    key_size = number       # 2048
    key_opts = list(string) # If empty the all rights are added
  }))
  description = "A list of Key Vault Keys."
  default     = []
}
variable "network_acls" {
  type = object({
    default_action             = string       # (Required) Specifies the default action of allow or deny when no other rules match.
    bypass                     = string       # (Required) Specifies which traffic can bypass the network rules. Possible values are AzureServices and None.
    ip_rules                   = list(string) # (Optional) One or more IP Addresses, or CIDR Blocks which should be able to access the Key Vault.
    virtual_network_subnet_ids = list(string) # (Optional) One or more Subnet ID's which should be able to access this Key Vault.
  })
  description = "(Required) Network rules for the Key Vault."
  default = {
    default_action             = "Allow"
    bypass                     = "AzureServices"
    ip_rules                   = []
    virtual_network_subnet_ids = []
  }
  validation {
    condition     = can(regex("^Allow$|^Deny$", var.network_acls.default_action))
    error_message = "The variable 'network_acls' must have valid default_action: 'Allow', 'Deny' ."
  }
}
/*
variable "certificates" {
  type = list(object({
    name               = string
    key_size           = number
    auth_server        = bool
    auth_client        = bool
    dns_names          = list(string)
    subject            = string
    validity_in_months = number
  }))
  description = "A list of Key Vault certificates"
  default     = []
}
*/
variable "tags" {
  type        = map(any)
  description = "A mapping of tags to assign to the resource."
  default     = {}
}
