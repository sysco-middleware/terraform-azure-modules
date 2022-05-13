# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting

resource "azurerm_monitor_diagnostic_setting" "mds" {
  depends_on = [
    data.azurerm_resource_group.rg,
    data.azurerm_log_analytics_workspace.law,
    data.azurerm_monitor_diagnostic_categories.mdc
  ]
  count = length(var.target_resource_ids)

  name               = var.name
  target_resource_id = var.target_resource_ids[count.index]

  # One of eventhub_authorization_rule_id, log_analytics_workspace_id and storage_account_id must be specified.
  log_analytics_workspace_id     = data.azurerm_log_analytics_workspace.law.id #(Optional) Specifies the ID of a Log Analytics Workspace where Diagnostics Data should be sent.
  log_analytics_destination_type = var.law_dst_type

  dynamic "log" {
    for_each = toset(data.azurerm_monitor_diagnostic_categories.mdc[count.index].logs) # A list of the Log Categories supported for this Resource.
    iterator = each

    content {
      category = each.key # https://docs.microsoft.com/en-us/azure/azure-monitor/essentials/resource-logs-schema#supported-log-categories-per-resource-type
      enabled  = var.log.enabled

      retention_policy {
        enabled = var.log.retention_policy_enabled
        days    = var.log.retention_policy_days
      }
    }
  }
  provisioner "local-exec" {
    command = "echo id: ${var.target_resource_ids[count.index]}"
  }

  # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/monitor_diagnostic_categories
  # Metric export is not enabled for CDN Endpoints or Network Security Groups
  dynamic "metric" {
    for_each = can(regex("/Microsoft\\.Cdn|networkSecurityGroups/", var.target_resource_ids[count.index])) ? [] : [1] # Note: regex is case-sensitive
    #iterator = each

    content {
      category = var.metric.category
      enabled  = var.metric.enabled

      retention_policy {
        enabled = var.metric.retention_policy_enabled
        days    = var.metric.retention_policy_days #  (Optional) The number of days for which this Retention Policy should apply. Setting this to 0 will retain the events indefinitely.
      }
    }
  }

  #lifecycle {
  #  ignore_changes = [target_resource_id, log_analytics_workspace_id]
  #}
}
