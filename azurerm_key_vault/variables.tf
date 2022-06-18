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
  description = "(Required) The Name of the SKU used for this Key Vault. Possible values are standard and premium."
  default     = "standard"
  validation {
    condition     = can(regex("^standard$|^premium$", var.sku_name))
    error_message = "The variable 'sku_name' must have valid default_action: 'standard', 'premium' ."
  }
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
variable "rbac_roles" {
  type = list(object({
    role_definition_name = string
    principal_id         = string
  }))
  description = "Role definition name to give access to, ex: Key Vault Administrator. Note: var.enable_rbac_authorization must be true"
  default     = []
}
variable "access_policies" {
  type = list(object({
    object_id               = string       # (Required) The object ID of a user, service principal or security group in the Azure Active Directory tenant for the vault. The object ID must be unique for the list of access policies.
    key_permissions         = list(string) # "Create", "Get", "Purge", "Recover", "List", "Delete", "Update", "Backup", "Restore"
    secret_permissions      = list(string) # "Get", "List", "Set", "Delete", "Purge", "Recover", "Backup", "Restore"
    certificate_permissions = list(string) # "Backup", "Create", "Delete", "DeleteIssuers", "Get", "GetIssuers", "Import", "List", "ListIssuers", "ManageContacts", "ManageIssuers", "Purge", "Recover", "Restore", "SetIssuers", "Update"
    storage_permissions     = list(string) # "Backup", "Delete","Get","List","Restore","Update","Recover","RegenerateKey". Is ignored if sku is premium. 
  }))
  description = "The Access Policies. This is ignored if variable 'enable_rbac_authorization' is true."
  default     = []
}
variable "access_policies_rbac" {
  type = list(object({
    object_id        = string # (Required) The object ID of a user, service principal or security group in the Azure Active Directory tenant for the vault. The object ID must be unique for the list of access policies.
    key_role         = string # Owner, Contributor, Reader
    secret_role      = string # Owner, Contributor, Reader
    certificate_role = string # Owner, Contributor, Reader
    storage_role     = string # Owner, Contributor, Reader. Is ignored if sku is premium. 
  }))
  description = "Predifined Access Policy permissions using RBAC definition names. This is ignored if variable 'enable_rbac_authorization' is true."
  default = [
    {
      object_id        = null
      key_role         = "Contributor"
      secret_role      = "Contributor"
      certificate_role = "Contributor"
      storage_role     = "Reader"
    }
  ]
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
variable "certificates_pfx" {
  type = list(object({
    name     = string
    pfx_file = string
    password = string
  }))
  description = "A list of Key Vault PFX certificates"
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
