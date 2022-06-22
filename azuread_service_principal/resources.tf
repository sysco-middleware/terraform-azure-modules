# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/service_principal
# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal

resource "azuread_application" "app" {
  count = var.application_id == null ? 1 : 0

  display_name = var.name
  owners       = local.owners
}

resource "azuread_service_principal" "sp" {
  depends_on = [azuread_application.app]

  account_enabled               = var.enabled
  application_id                = local.application_id
  app_role_assignment_required  = var.app_role_required
  owners                        = local.owners
  description                   = var.description
  login_url                     = var.login_url
  notes                         = var.notes
  notification_email_addresses  = var.notifications
  preferred_single_sign_on_mode = var.preferred_sso_mode
  use_existing                  = var.use_existing
  alternative_names             = set(var.alternative_names)

  feature_tags {
    enterprise = var.is_enterprise
    gallery    = var.is_gallery

    # custom_single_sign_on - (Optional) Whether this service principal represents a custom SAML application. Enabling this will assign the
    # hide - (Optional) Whether this app is invisible to users in My Apps and Office 365 Launcher. Enabling this will assign the HideApp tag. Defaults to false.
  }

  saml_single_sign_on {
    for_each = local.sso_enabled ? [1] : [0]

    relay_state = var.sso_relay_state
  }
}

resource "time_rotating" "days" {
  rotation_days = var.rotation_days
}

resource "azuread_service_principal_password" "pass" {
  depends_on = [azuread_service_principal.sp]

  service_principal_id = azuread_service_principal.sp.object_id
  rotate_when_changed = {
    rotation = time_rotating.days.id
  }
}
