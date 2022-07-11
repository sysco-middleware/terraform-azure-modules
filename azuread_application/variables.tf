variable "display_name" {
    description = "Required) The display name for the application."
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


variable "expose_api" {
  type = object({
    claims_enabled       = bool # (Optional) Allows an application to use claims mapping without specifying a custom signing key. Defaults to false.
    access_token_version = number # (Optional) The access token version expected by this resource. Must be one of 1 or 2, and must be 2 when sign_in_audience is either AzureADandPersonalMicrosoftAccount or PersonalMicrosoftAccount Defaults to 1.
    client_applications  = list(string) # (Optional) A set of known application IDs (client IDs), used for bundling consent if you have a solution that contains two parts: a client app and a custom web API app.
    oauth2_perm_scopes = list(object({ # (Optional) One or more oauth2_permission_scope blocks to describe delegated permissions exposed by the web API represented by this application.
      ac_description  = string # (Required) Delegated permission description that appears in all tenant-wide admin consent experiences, intended to be read by an administrator granting the permission on behalf of all users.
      ac_display_name = string # (Required) Display name for the delegated permission, intended to be read by an administrator granting the permission on behalf of all users.
      enabled         = bool # (Optional) Determines if the permission scope is enabled. Defaults to true
      id              = string # (Required) The unique identifier of the delegated permission. Must be a valid UUID. Use random_uuid (https://github.com/hashicorp/terraform-provider-azuread/tree/main/examples/application)
      type            = string # (Required) Whether this delegated permission should be considered safe for non-admin users to consent to on behalf of themselves, or whether an administrator should be required for consent to the permissions. Defaults to User. Possible values are User or Admin.
      uc_description  = string # (Optional) Delegated permission description that appears in the end user consent experience, intended to be read by a user consenting on their own behalf.
      uc_display_name = string # (Optional) Display name for the delegated permission that appears in the end user consent experience.
      value  = string # (Optional) The value that is used for the scp claim in OAuth 2.0 access tokens.
    }))
  })
  description = "(Optional) An api block which configures API related settings for this application."
  # Unlike in the Azure Portal, applications created with the Terraform AzureAD provider do not get assigned a default 'user_impersonation' scope. This block for the user_impersonation scope needs to be included if you need it for your application.
  default = {
    claims_enabled       = true
    access_token_version = 2
    client_applications  = []
    oauth2_perm_scopes   = [
        {
            ac_description
        }
    ]
  }
}

variable "app_roles" {
  type = list(object({
    allowed_types = list(string) # (Required) Specifies whether this app role definition can be assigned to users and groups by setting to User, or to other applications (that are accessing this application in a standalone scenario) by setting to Application, or to both.
    description   = string # (Required) Description of the app role that appears when the role is being assigned and, if the role functions as an application permissions, during the consent experiences.
    display_name  = string # (Required) Display name for the app role that appears during app role assignment and in consent experiences.
    enabled       = bool # (Optional) Determines if the app role is enabled. Defaults to true
    id            = string # (Required) The unique identifier of the app role. Must be a valid UUID.
    value         = string # (Optional) The value that is used for the roles claim in ID tokens and OAuth 2.0 access tokens that are authenticating an assigned service or user principal.
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
    resource_app_id = string # (Required) The unique identifier for the resource that the application requires access to. This should be the Application ID of the target application. Example: data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph
    resource_access = list({ # (Required) A collection of resource_access blocks as documented below, describing OAuth2.0 permission scopes and app roles that the application requires from the specified resource.
      id   = string # (Required) The unique identifier for an app role or OAuth2 permission scope published by the resource application. Example: "df021288-bdef-4463-88db-98f22de89214" <=> User.Read.All
      type = string # Required) Specifies whether the id property references an app role or an OAuth2 permission scope. Possible values are Role or Scope.
    })
  }))
  description = "(Optional) The required resource access."
  default     = []
}

variable "redirect_uris" {
    type = list(string)
    description = " (Optional) A set of URLs where user tokens are sent for sign-in, or the redirect URIs where OAuth 2.0 authorization codes and access tokens are sent. Must be a valid https URL."
    default = []
}