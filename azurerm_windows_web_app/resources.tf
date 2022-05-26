# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_web_app
resource "azurerm_windows_web_app" "wwa" {
  depends_on = [
    data.azurerm_resource_group.rg,
  data.azurerm_service_plan.sp]

  enabled                    = var.enabled
  name                       = var.name
  location                   = data.azurerm_resource_group.rg.location
  resource_group_name        = data.azurerm_resource_group.rg.name
  service_plan_id            = data.azurerm_service_plan.sp.id
  https_only                 = var.https_only
  client_affinity_enabled    = var.client_affinity_enabled
  client_certificate_enabled = local.client_certificate_enabled
  client_certificate_mode    = var.client_certificate_mode
  tags                       = var.tags

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
    # TODO: api_management_api_id -  (Optional) The API Management API ID this Windows Web App Slot is associated with.
    # TODO: app_command_line - (Optional) App command line to launch, e.g. /sbin/myserver -b 0.0.0.0.
    # TODO: container_registry_managed_identity_client_id - (Optional) The Client ID of the Managed Service Identity to use for connections to the Azure Container Registry.
    # TODO: container_registry_use_managed_identity - (Optional) Should connections for Azure Container Registry use Managed Identity.

    auto_heal_enabled = var.auto_heal_enabled
    dynamic "auto_heal_setting" {
      for_each = var.auto_heal_enabled != null ? [var.auto_heal_setting] : []
      iterator = each

      content {
        action {
          action_type = each.value.action.action_type
          custom_action {
            executable = each.value.action.custom_action.executable
            parameters = each.value.action.custom_action.parameters
          }

          minimum_process_execution_time = each.value.action.minimum_process_execution_time
        }
        trigger {
          private_memory_kb = each.value.trigger.private_memory_kb
          requests {
            count    = each.value.trigger.requests.count
            interval = each.value.trigger.requests.interval
          }
          slow_request {
            count      = each.value.trigger.slow_request.count
            interval   = each.value.trigger.slow_request.interval
            time_taken = each.value.trigger.slow_request.time_taken
            path       = each.value.trigger.slow_request.path
          }
          status_code {
            count             = each.value.trigger.status_code.count
            interval          = each.value.trigger.status_code.interval
            status_code_range = each.value.trigger.status_code.status_code_range
            sub_status        = each.value.trigger.status_code.sub_status
            win32_status      = each.value.trigger.status_code.win32_status
            path              = each.value.trigger.status_code.path
          }
        }
      }
    }

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
    ftps_state             = local.ftps_state
    ip_restriction         = var.ip_restrictions
    worker_count           = var.worker_count
    load_balancing_mode    = var.load_balancing_mode
    managed_pipeline_mode  = var.managed_pipeline_mode
    minimum_tls_version    = var.minimum_tls_version
    vnet_route_all_enabled = var.vnet_route_all_enabled
    #default_documents     = local.default_documents

    # TODO: remote_debugging_enabled - (Optional) Should Remote Debugging be enabled. Defaults to false.
    # TODO: remote_debugging_version - (Optional) The Remote Debugging Version. Possible values include VS2017 and VS2019.
    # TODO: scm*
    # TODO: virtual_application - (Optional) One or more virtual_application blocks as defined below.

    application_stack {
      current_stack          = var.current_stack
      dotnet_version         = var.current_stack == "dotnetcore" ? "v3.0" : local.dotnet_version
      java_container         = local.java_container
      java_container_version = local.java_container_version
      java_version           = local.java_version
      node_version           = local.node_version
      php_version            = local.php_version
      python_version         = local.python_version
    }
  }

  logs {
    detailed_error_messages = var.logs.detailed_error_messages
    failed_request_tracing  = var.logs.failed_request_tracing

    dynamic "application_logs" {
      for_each = var.application_logs.enabled ? [var.application_logs] : []
      iterator = each
      content {
        azure_blob_storage {
          level             = each.value.azure_blob_storage.level
          sas_url           = each.value.azure_blob_storage.sas_url
          retention_in_days = each.value.azure_blob_storage.retention_in_days
        }
        file_system_level = each.value.file_system_level
      }
    }
    dynamic "http_logs" {
      for_each = var.http_logs.enabled ? [var.http_logs] : []
      iterator = each
      content {
        file_system {
          retention_in_days = each.value.file_system.retention_in_days
          retention_in_mb   = each.value.file_system.retention_in_mb
        }
        azure_blob_storage {
          sas_url           = each.value.azure_blob_storage.sas_url
          retention_in_days = each.value.azure_blob_storage.retention_in_days
        }
      }
    }
  }

  dynamic "storage_account" {
    for_each = length(var.storage_account) > 0 ? var.storage_account : []
    iterator = each

    content {
      access_key   = each.value.access_key
      account_name = each.value.account_name
      name         = each.value.name
      share_name   = each.value.share_name
      type         = each.value.type
      mount_path   = each.value.mount_path
    }
  }

  lifecycle {
    ignore_changes = [tags, location, app_settings]
  }
}
