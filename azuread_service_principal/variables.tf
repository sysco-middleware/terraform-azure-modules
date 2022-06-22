variable "enabled" {
  type        = bool
  description = "(Optional) Whether or not the service principal account is enabled. Defaults to true."
  default     = true
}
variable "name" {}
variable "description" {
  type        = string
  description = "(Optional) A description of the service principal provided for internal end-users."
  default     = ""
}

variable "application_id" {
  type        = string
  description = "(Required/Optional) The application ID (client ID) of the application for which to create a service principal. If omitted , the a application will be created in the same name."
  default     = null
}

variable "is_enterprise" {
  type        = bool
  description = " (Optional) Whether this service principal represents an Enterprise Application. Enabling this will assign the WindowsAzureActiveDirectoryIntegratedApp tag. Defaults to false."
  default     = false
}
variable "is_gallery" {
  type        = bool
  description = "(Optional) Whether this service principal represents a gallery application. Enabling this will assign the WindowsAzureActiveDirectoryGalleryApplicationNonPrimaryV1 tag. Defaults to false."
  default     = false
}
variable "rotation_days" {
  type        = number
  description = "(Optional) A map of arbitrary key/value pairs that will force recreation of the password when they change, enabling password rotation based on external conditions such as a rotating timestamp. Changing this forces a new resource to be created."
  default     = 365
}
variable "app_role_required" {
  type        = bool
  description = "(Optional) Whether this service principal requires an app role assignment to a user or group before Azure AD will issue a user or access token to the application. Defaults to false."
  default     = false
}

variable "owners" {
  type        = list(string)
  description = "(Optional) A set of object IDs of principals that will be granted ownership of the service principal. Supported object types are users or service principals. By default, current terraform will be are assigned."
  default     = []
}

variable "notifications" {
  type        = list(string)
  description = "(Optional) A set of email addresses where Azure AD sends a notification when the active certificate is near the expiration date. This is only for the certificates used to sign the SAML token issued for Azure AD Gallery applications."
  default     = []
}

variable "notes" {
  type        = string
  description = "(Optional) A free text field to capture information about the service principal, typically used for operational purposes."
  default     = null
}

variable "preferred_sso_mode" {
  type        = string
  description = "(Optional) The single sign-on mode configured for this application. Azure AD uses the preferred single sign-on mode to launch the application from Microsoft 365 or the Azure AD My Apps. Supported values are oidc, password, saml or notSupported. Omit this property or specify a blank string to unset."
  default     = null
  validation {
    condition     = can(regex("oidc|password|saml|notSupported", var.preferred_sso_mode)) || var.preferred_sso_mode == null
    error_message = "The variable 'preferred_sso_mode' must be one of: oidc|password|saml|notSupported"
  }
}

variable "sso_relay_state" {
  type        = string
  description = "(Optional) The relative URI the service provider would redirect to after completion of the single sign-on flow."
  default     = null
}

variable "use_existing" {
  type        = bool
  description = "(Optional) When true, any existing service principal linked to the same application will be automatically imported. When false, an import error will be raised for any pre-existing service principal."
  default     = true
}

variable "" {
  type        = string
  description = ""
  default     = ""
}


variable "alternative_names" {
  type        = string
  description = "(Optional) A set of alternative names, used to retrieve service principals by subscription, identify resource group and full resource ids for managed identities."
  default     = []
}

