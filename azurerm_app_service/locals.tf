locals {
  created_date        = formatdate("YYYY-MM-DD hh:mm:ss", timestamp())
  start_time          = formatdate("YYYY-MM-DD hh:mm:ss", timestamp())
  created_datetimeUTC = formatdate("YYYY-MM-DD hh:mm:ss ZZZ", timestamp())

  default_documents = sort(["index.html", "index.js", "default.html", "default.aspx", "hostingstart.htm", "iisstart.htm"])
  #  linux_fx_version = "DOTNETCORE|3.1"
  app_kinds = {
    "windows" = {
      dotnet_framework_version = null # "DOTNETCORE|3.1" # Defaultis v4.0
      linux_fx_version         = null
      windows_fx_version       = var.fx_version
    }
    "linux" = {
      dotnet_framework_version = null # ""
      linux_fx_version         = var.fx_version
      windows_fx_version       = null
    }
  }
  dotnet_framework_version = local.app_kinds[var.app_kind].dotnet_framework_version
  linux_fx_version         = local.app_kinds[var.app_kind].linux_fx_version
  windows_fx_version       = local.app_kinds[var.app_kind].windows_fx_version

  appsettings_default = {
    WEBSITE_DYNAMIC_CACHE                   = "0"
    WEBSITE_RUN_FROM_PACKAGE                = 1
    WEBSITE_ENABLE_SYNC_UPDATE_SITE         = true
    WEBSITE_TIME_ZONE                       = "W. Europe Standard Time"
    InstrumentationEngine_EXTENSION_VERSION = "disabled"
  }
  appsettings_appinsights = var.app_insights.enabled ? {
    APPINSIGHTS_INSTRUMENTATIONKEY             = var.app_insights.instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING      = var.app_insights.connection_string
    ApplicationInsightsAgent_EXTENSION_VERSION = "~2"
  } : {}
  app_settings = merge(local.appsettings_default, local.appsettings_appinsights, var.app_settings)
}
