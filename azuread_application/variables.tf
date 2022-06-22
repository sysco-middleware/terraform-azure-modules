variable "display_name" {}
variable "description" {
  type        = string
  description = "(Optional) A description of the service principal provided for internal end-users."
  default     = ""
}
variable "identifier_uris" {
  type        = list(string)
  description = ""
  default     = []
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
  description = ""
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
  description = ""
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