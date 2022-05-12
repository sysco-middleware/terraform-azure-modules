# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_web_app
resource "azurerm_app_service" "wa" {
  depends_on = [
    data.azurerm_resource_group.rg,
  data.azurerm_app_service_plan.asp]

  enabled                 = var.enabled
  name                    = var.name
  resource_group_name     = data.azurerm_resource_group.rg.name
  location                = data.azurerm_resource_group.rg.location
  app_service_plan_id     = data.azurerm_app_service_plan.asp.id
  client_affinity_enabled = var.client_affinity_enabled
  client_cert_enabled     = var.client_cert_enabled
  client_cert_mode        = var.client_cert_mode
  https_only              = var.https_only
  tags                    = var.tags

  app_settings = local.app_settings

  dynamic "auth_settings" {
    for_each = length(var.auth_settings) > 0 ? var.auth_settings : []
    iterator = each
    content {
      enabled          = each.value.enabled
      default_provider = each.value.provider
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

  identity {
    # (Required) Specifies the identity type of the Function App. Possible values are SystemAssigned (where Azure will generate a Service Principal for you), 
    # UserAssigned where you can specify the Service Principal IDs in the identity_ids field, and SystemAssigned, UserAssigned which assigns both a system managed identity as well as the specified user assigned identities.
    type = "SystemAssigned"
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
        retention_period_in_days = each.value.schedule.retention_period_in_days
        start_time               = each.value.schedule.start_time
      }
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
    detailed_error_messages_enabled = var.detailed_error_messages_enabled
    failed_request_tracing_enabled  = var.failed_request_tracing_enabled
  }

  site_config {
    #acr_use_managed_identity_credentials - (Optional) Are Managed Identity Credentials used for Azure Container Registry pull
    always_on        = true                 # (Optional) Should the app be loaded at all times? Must be set to false when App Service Plan in the Free or Shared Tiers  Defaults to false
    app_command_line = var.app_command_line # (Optional) App command line to launch, e.g. /sbin/myserver -b 0.0.0.0.

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

    # https://docs.microsoft.com/en-us/azure/app-service/deploy-continuous-deployment?tabs=github#comments
    default_documents = local.default_documents
    # dotnet_framework_version:
    ## (Optional) The version of the .net framework's CLR used in this App Service. 
    ## Possible values are v2.0 (which will use the latest version of the .net framework for the .net CLR v2 - currently .net 3.5), 
    ## v4.0 (which corresponds to the latest version of the .net CLR v4 - which at the time of writing is .net 4.7.1), v5.0 and v6.0
    dotnet_framework_version  = local.dotnet_framework_version
    linux_fx_version          = local.linux_fx_version
    windows_fx_version        = local.windows_fx_version
    health_check_path         = var.health_check_path
    managed_pipeline_mode     = "Integrated"
    min_tls_version           = "1.2"
    websockets_enabled        = false
    vnet_route_all_enabled    = var.vnet_route_all_enabled
    http2_enabled             = var.http2_enabled
    use_32_bit_worker_process = var.use_32_bit_worker_process
    scm_type                  = var.scm_type
    ftps_state                = var.ftps_state
    ip_restriction            = var.ip_restrictions
  }

  dynamic "storage_account" {
    for_each = var.storage_account.enabled ? [var.storage_account] : []
    iterator = each
    content {
      name         = each.value.name
      type         = each.value.type
      share_name   = each.value.share_name
      access_key   = each.value.access_key
      account_name = each.value.account_name
      mount_path   = each.value.mount_path
    }
  }

  lifecycle {
    ignore_changes = [tags["updated_date"], location, app_settings]
  }
}


/*
resource "azurerm_app_service_certificate" "cert" {
  name                = var.cert_name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  key_vault_secret_id = "https://${var.kv_name}.vault.azure.net/certificates/${var.cert_name}/766c23ae979c4b0fad603937af2511a5"
}
*/

/*
resource "azurerm_app_service_custom_hostname_binding" "ashb" {
  count               = length(var.custom_hostnames)
  hostname            = var.custom_hostnames[count.index]
  app_service_name    = var.name
  resource_group_name = var.rg.name
}
*/
