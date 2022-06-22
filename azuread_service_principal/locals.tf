locals {
  owners         = length(var.owners) == 0 ? [data.azuread_client_config.current.object_id] : var.owners
  sso_enabled    = var.sso_relay_state != null && var.preferred_sso_mode != null
  application_id = var.application_id == null ? azuread_application.app.application_id : var.application_id
}