locals {
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
  default_documents        = sort(["index.html", "index.js", "default.html", "default.aspx", "hostingstart.htm", "iisstart.htm"])
  dotnet_framework_version = local.app_kinds[var.app_kind].dotnet_framework_version
  linux_fx_version         = local.app_kinds[var.app_kind].linux_fx_version
  windows_fx_version       = local.app_kinds[var.app_kind].windows_fx_version
  appsettings_default = {
    WEBSITE_DYNAMIC_CACHE           = "0"
    WEBSITE_RUN_FROM_PACKAGE        = 1
    WEBSITE_ENABLE_SYNC_UPDATE_SITE = true
    WEBSITE_TIME_ZONE               = "Central Europe Standard Time"
  }
  app_settings = merge(local.appsettings_default, var.app_settings)
}
