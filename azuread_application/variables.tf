variable "display_name" {
    description = "Required) The display name for the application."
}
variable "description" {
  type        = string
  description = "(Optional) A description of the service principal provided for internal end-users."
  default     = ""
}

variable "public_client_enabled" {
    type = bool 
    description = "(Optional) Specifies whether the fallback application is a public client. Appropriate for apps using token grant flows that don't use a redirect URI. Defaults to false."
    default = false
}

variable "identifier_uris" {
  type        = list(string)
  description = ""
  default     = []
}

variable "device_only" {
    type = bool
    description = "(Optional) Specifies whether this application supports device authentication without a user. Defaults to false."
    default = false
}

variable "group_membership_claims" {
    type = bool
    description = "(Optional) Configures the groups claim issued in a user or OAuth 2.0 access token that the app expects. Possible values are None, SecurityGroup, DirectoryRole, ApplicationGroup or All."
    default = "None"
    validation {
    condition     = can(regex("None|SecurityGroup|DirectoryRole|ApplicationGroup|All", var.preferred_sso_mode)) || var.preferred_sso_mode == null
    error_message = "The variable 'preferred_sso_mode' must be one of: oidc|password|saml|notSupported"
  }
}


variable "api" {
  type = object({
    claims_enabled       = bool
    access_token_version = number
    client_applications  = list(string)
    oauth2_perm_scopes = list(object({
      ac_description  = string
      ac_display_name = string
      enabled         = bool
      id              = string
      type            = string
      uc_description  = string
      uc_display_name = string
    }))
  })
  description = "(Optional) An api block which configures API related settings for this application."
  default = {
    claims_enabled       = true
    access_token_version = 2
    client_applications  = []
    oauth2_perm_scopes   = []
  }
}

variable "app_roles" {
  type = list(object({
    allowed_types = list(string)
    description   = string
    display_name  = string
    enabled       = bool
    id            = string
    value         = string
  }))
  description = "(Optional) A collection of app_role blocks For more information see https://docs.microsoft.com/en-us/azure/architecture/multitenant-identity/app-roles on Application Roles."
  default     = []
}

variable "is_enterprise" {
  type        = bool
  description = "(Optional) Whether this service principal represents an Enterprise Application. Enabling this will assign the WindowsAzureActiveDirectoryIntegratedApp tag. Defaults to false."
  default     = false
}

variable "is_gallery" {
  type        = bool
  description = "(Optional) Whether this service principal represents a gallery application. Enabling this will assign the WindowsAzureActiveDirectoryGalleryApplicationNonPrimaryV1 tag. Defaults to false."
  default     = false
}

variable "required_accesses" {
  type = list(object({
    resource_app_id = string # data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph
    resources = list({
      id   = string # "df021288-bdef-4463-88db-98f22de89214" # User.Read.All
      type = scrope
    })
  }))
  description = "(Optional) The required resource access."
  default     = []
}