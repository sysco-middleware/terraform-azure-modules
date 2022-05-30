# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_function_app
resource "azurerm_windows_function_app" "wfa" {
  depends_on = [
    data.azurerm_resource_group.rg,
    data.azurerm_service_plan.sp,
  data.azurerm_storage_account.sa]

  enabled                     = var.enabled
  name                        = var.name
  location                    = data.azurerm_resource_group.rg.location
  resource_group_name         = data.azurerm_resource_group.rg.name
  service_plan_id             = data.azurerm_service_plan.sp.id
  https_only                  = var.https_only
  builtin_logging_enabled     = var.builtin_logging_enabled
  storage_account_name        = data.azurerm_storage_account.sa.name
  storage_account_access_key  = data.azurerm_storage_account.sa.primary_access_key
  client_certificate_enabled  = local.client_certificate_enabled
  client_certificate_mode     = local.client_certificate_mode
  daily_memory_time_quota     = var.daily_memory_time_quota
  functions_extension_version = var.runtime_version
  tags                        = var.tags

  # TODO: key_vault_reference_identity_id - (Optional) The User Assigned Identity ID used for accessing KeyVault secrets. The identity must be assigned to the application in the identity block. For more information see - Access vaults with a user-assigned identity


  app_settings = local.app_settings

  dynamic "auth_settings" {
    for_each = length(var.auth_settings) > 0 ? var.auth_settings : []
    iterator = each
    content {
      enabled          = each.value.enabled
      default_provider = each.value.default_provider
      active_directory {
        client_id         = each.value.active_directory.client_id     # (Required) The Client ID of this relying party application. Enables OpenIDConnection authentication with Azure Active Directory.
        client_secret     = each.value.active_directory.client_secret # (Optional) The Client Secret of this relying party application. If no secret is provided, implicit flow will be used.
        allowed_audiences = each.value.active_directory.audiences
      }

      # runtime_version = each.value.runtime_version # (Optional) The Runtime Version of the Authentication / Authorization feature in use for the Windows Function App.
      # allowed_external_redirect_urls = each.value.redirect_urls # (Optional) Specifies a list of External URLs that can be redirected to as part of logging in or logging out of the Windows Function App.

    }
  }

  dynamic "connection_string" {
    for_each = length(var.connection_strings) > 0 ? var.connection_strings : []
    iterator = each
    content {
      name  = each.value.name
      type  = each.value.type
      value = each.value.conn
    }
  }

  dynamic "identity" {
    for_each = var.managed_identity_type != null ? [1] : []
    content {
      type         = var.managed_identity_type
      identity_ids = local.identity_ids
    }
  }

  dynamic "backup" {
    for_each = var.backup.enabled ? [var.backup] : []
    iterator = each
    content {
      name                = each.value.name
      enabled             = each.value.enabled
      storage_account_url = each.value.storage_account_url

      schedule {
        frequency_interval       = each.value.schedule.frequency_interval
        frequency_unit           = each.value.schedule.frequency_unit
        keep_at_least_one_backup = each.value.schedule.keep_at_least_one_backup
        retention_period_days    = each.value.schedule.retention_period_days
        start_time               = each.value.schedule.start_time
      }
    }
  }

  site_config {
    always_on = var.always_on
    # TODO: api_definition_url - (Optional) The URL of the API definition that describes this Linux Function App.
    # TODO: api_management_api_id - (Optional) The ID of the API Management API for this Linux Function App.
    # TODO: app_command_line - (Optional) App command line to launch, e.g. /sbin/myserver -b 0.0.0.0.

    app_scale_limit                        = var.app_scale_limit
    application_insights_connection_string = var.app_insights.enabled ? var.app_insights.connection_string : null
    application_insights_key               = var.app_insights.enabled ? var.app_insights.instrumentation_key : null

    #Cross-Origin Resource Sharing (CORS) allows JavaScript code running in a browser on an external host to interact with your backend. Specify the origins that should be allowed to make cross-origin calls (for example: http://example.com:12345). To allow all, use "*" and remove all other origins from the list. 
    #Slashes are not allowed as part of domain or after TLD. Learn more
    dynamic "cors" {
      for_each = var.cors.enabled ? [var.cors] : []
      iterator = each
      content {
        allowed_origins     = each.value.allowed_origins
        support_credentials = each.value.support_credentials
      }
    }

    health_check_path      = var.health_check_path
    websockets_enabled     = var.websockets_enabled
    http2_enabled          = var.http2_enabled
    use_32_bit_worker      = var.use_32_bit_worker
    vnet_route_all_enabled = var.vnet_route_all_enabled
    ftps_state             = var.ftps_state
    ip_restriction         = var.ip_restrictions
    worker_count           = var.worker_count
    managed_pipeline_mode  = var.managed_pipeline_mode
    minimum_tls_version    = var.minimum_tls_version

    # TODO: pre_warmed_instance_count - (Optional) The number of pre-warmed instances for this Windows Function App. Only affects apps on an Elastic Premium plan.
    # TODO: remote_debugging_enabled - (Optional) Should Remote Debugging be enabled. Defaults to false.
    # TODO: remote_debugging_version - (Optional) The Remote Debugging Version. Possible values include VS2017 and VS2019.
    # TODO: runtime_scale_monitoring_enabled - (Optional) Should Scale Monitoring of the Functions Runtime be enabled?
    # TODO: scm*

    dynamic "app_service_logs" {
      for_each = local.is_consumption_plan ? [] : [var.app_service_logs]
      iterator = each

      content {
        disk_quota_mb         = each.value.disk_quota_mb
        retention_period_days = each.value.retention_period_days
      }
    }

    application_stack {
      dotnet_version              = var.dotnet_version
      java_version                = var.java_version
      node_version                = var.node_version
      powershell_core_version     = var.powershell_core_version
      use_dotnet_isolated_runtime = var.use_dotnet_isolated_runtime
      use_custom_runtime          = var.use_custom_runtime
    }
  }

  lifecycle {
    ignore_changes = [tags, location, app_settings, storage_account_access_key]
  }
}
