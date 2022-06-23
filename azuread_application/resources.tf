# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/app_role_assignment
resource "azuread_application" "app" {
  display_name    = var.name
  identifier_uris = var.identifier_uris
  device_only_auth_enabled = var.device_only
  fallback_public_client_enabled = var.public_client_enabled
  group_membership_claims = var.group_membership_claims

  # TODO: optional_claims {}

  api {
    mapped_claims_enabled          = var.api.claims_enabled
    requested_access_token_version = var.api.access_token_version
    known_client_applications      = var.api.client_applications

    dynamic "oauth2_permission_scope" {
      for_each = length(var.api.oauth2_perm_scopes) > 0 ? var.var.api.oauth2_perm_scopes : []
      iterator = each

      content {
        admin_consent_description  = each.value.ac_description
        admin_consent_display_name = each.value.ac_display_name
        enabled                    = each.value.enabled
        id                         = each.value.id
        type                       = each.value.type
        user_consent_description   = each.value.uc_description
        user_consent_display_name  = each.value.uc_display_name
        value                      = each.value.value
      }
    }
  }

  dynamic "app_role" {
    for_each = length(var.app_roles) > 0 ? var.app_roles : []
    iterator = each

    content {
      allowed_member_types = each.value.allowed_member_types # ["User", "Application"]
      description          = each.value.description          #"Admins can manage roles and perform all task actions"
      display_name         = each.value.display_name         #"Admin"
      enabled              = each.value.enabled
      id                   = each.value.id
      value                = each.value.value
    }
  }

  feature_tags {
    enterprise = var.is_enterprise
    gallery    = var.is_gallery

    # custom_single_sign_on - (Optional) Whether this service principal represents a custom SAML application. Enabling this will assign the
    # hide - (Optional) Whether this app is invisible to users in My Apps and Office 365 Launcher. Enabling this will assign the HideApp tag. Defaults to false.
  }

  dynamic "required_resource_access" {
    for_each = length(var.required_accesses) > 0 ? var.required_accesses : []
    iterator = each

    content {
      resource_app_id = each.value.resource_app_id

      dynamic "resource_access" {
        for_each = length(each.value.resources) > 0 ? each.value.resources : []
        iterator = eachsub

        content {
          id   = eachsub.value.id
          type = eachsub.value.type
        }
      }
    }
  }

  web {
    homepage_url  = var.web.homepage_url
    logout_url    = var.web.logout_url
    redirect_uris = var.web.redirect_uris

    implicit_grant {
      access_token_issuance_enabled = true
      id_token_issuance_enabled     = true
    }
  }
}
