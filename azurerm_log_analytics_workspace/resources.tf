# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace
resource "azurerm_log_analytics_workspace" "law" {
  depends_on = [data.azurerm_resource_group.rg]

  name                       = var.name
  resource_group_name        = data.azurerm_resource_group.rg.name
  location                   = data.azurerm_resource_group.rg.location
  sku                        = var.sku
  retention_in_days          = var.retention_in_days
  daily_quota_gb             = var.daily_quota_gb
  internet_ingestion_enabled = true # (Optional) Should the Log Analytics Workflow support ingestion over the Public Internet? 
  internet_query_enabled     = true # Optional) Should the Log Analytics Workflow support querying over the Public Internet?
  # reservation_capacity_in_gb_per_day can only be used when the sku is set to CapacityReservation.
  #reservation_capacity_in_gb_per_day = 200 #(Optional) The capacity reservation level in GB for this workspace. Must be in increments of 100 between 100 and 5000.

  #permanently_delete_on_destroy = true # (Optional) Should the azurerm_log_analytics_workspace be permanently deleted (e.g. purged) when destroyed? Defaults to false.

  tags = var.tags

  lifecycle {
    ignore_changes = [tags["updated_date"], location]
  }
}

resource "azurerm_management_lock" "law_lock" {
  depends_on = [azurerm_log_analytics_workspace.law]
  count      = var.lock_resource ? 1 : 0

  name       = "CanNotDelete"
  scope      = azurerm_log_analytics_workspace.law.id
  lock_level = "CanNotDelete"
  notes      = "Terraform: This prevents accidental deletion of this resource."
}


///////////////////////////////////////////////////////////////////////
//////////// LOG ANALYTICS LINKED STORAGE

resource "azurerm_log_analytics_linked_storage_account" "lalsa" {
  depends_on = [azurerm_log_analytics_workspace.law, data.azurerm_storage_account.sa]
  count      = var.sa_name == null ? 0 : 1

  data_source_type      = var.data_source_type
  resource_group_name   = var.rg_name
  workspace_resource_id = azurerm_log_analytics_workspace.law.id
  storage_account_ids   = var.sa_name == null ? [] : [data.azurerm_storage_account.sa[count.index].id]

  #lifecycle {
  #ignore_changes = [workspace_resource_id]
  #}
}

resource "azurerm_log_analytics_storage_insights" "lalsi" {
  depends_on = [azurerm_log_analytics_workspace.law, data.azurerm_storage_account.sa]
  count      = var.sa_name == null ? 0 : 1

  name                = "${var.name}-storage-insights"
  resource_group_name = var.rg_name
  workspace_id        = azurerm_log_analytics_workspace.law.id

  storage_account_id  = data.azurerm_storage_account.sa[count.index].id
  storage_account_key = data.azurerm_storage_account.sa[count.index].primary_access_key

  #lifecycle {
  #  ignore_changes = [workspace_id]
  #}
}

///////////////////////////////////////////////////////////////////////
//////////// RBAC
resource "azurerm_role_assignment" "law_role" {
  depends_on = [azurerm_log_analytics_workspace.law]
  count      = var.enable_rbac_authorization ? length(var.rbac_roles) : 0

  scope                = azurerm_log_analytics_workspace.law.id
  role_definition_name = var.rbac_roles[count.index].role_definition_name
  principal_id         = var.rbac_roles[count.index].principal_id
}
