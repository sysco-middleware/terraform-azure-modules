locals {
  created_datetimeUTC = formatdate("YYYY-MM-DD hh:mm:ss ZZZ", timestamp())

  appsettings_default = {
    WEBSITE_DYNAMIC_CACHE                   = "0"
    WEBSITE_RUN_FROM_PACKAGE                = 1
    WEBSITE_ENABLE_SYNC_UPDATE_SITE         = true
    WEBSITE_TIME_ZONE                       = "W. Europe Standard Time"
    InstrumentationEngine_EXTENSION_VERSION = "disabled"
  }
  app_settings = merge(local.appsettings_default, var.app_settings)
  identity_ids = var.managed_identity_type == "UserAssigned" || var.managed_identity_type == "SystemAssigned, UserAssigned" ? toset(var.managed_identity_ids) : null

  is_consumption_plan = can(regex("Y1", data.service_plan.sp.sku_name)) || can(regex("FuntionApp", data.service_plan.sp.kind))
}
