
resource "azuread_group" "sql_admin_group" {
  depends_on = [data.azuread_client_config.current]

  display_name = var.sql_admin_group
  #mail_nickname           = var.sql_admin_group # Forces replacement is activated (destroyed)
  mail_enabled     = false
  security_enabled = true
  #prevent_duplicate_names = true
  description = "The SQL identity group of the Azure AD Administrator of the SQL Server."

  owners  = [data.azuread_client_config.current.object_id]
  members = concat(var.member_admin_ids, var.member_dev_ids)
}

resource "azurerm_key_vault_secret" "kv_secret_admin_user" {
  depends_on = [data.azurerm_key_vault.kv]

  name         = var.admin_user.name
  value        = var.admin_user.value
  content_type = var.admin_user.description

  key_vault_id = data.azurerm_key_vault.kv.id

  lifecycle {
    ignore_changes = [key_vault_id]
  }
}

resource "azurerm_key_vault_secret" "kv_secret_admin_pass" {
  depends_on = [data.azurerm_key_vault.kv]

  name         = var.admin_pass.name
  value        = var.admin_pass.value
  content_type = var.admin_pass.description

  key_vault_id = data.azurerm_key_vault.kv.id

  lifecycle {
    ignore_changes = [key_vault_id]
  }
}

resource "azurerm_mssql_server" "sql" {
  depends_on = [
    azuread_group.sql_admin_group,
    data.azurerm_resource_group.rg,
    azurerm_key_vault_secret.kv_secret_admin_user,
    azurerm_key_vault_secret.kv_secret_admin_pass
  ]

  name                          = var.name
  resource_group_name           = data.azurerm_resource_group.rg.name
  location                      = data.azurerm_resource_group.rg.location
  version                       = var.sql_version
  administrator_login           = var.admin_user.value
  administrator_login_password  = var.admin_pass.value
  minimum_tls_version           = var.minimum_tls_version
  public_network_access_enabled = var.public_enabled

  # https://go.microsoft.com/fwlink/?LinkID=616886
  azuread_administrator {
    login_username = var.sql_admin_group
    object_id      = azuread_group.sql_admin_group.object_id
  }
  identity {
    type = "SystemAssigned"
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [tags, location, administrator_login, version]
  }
}

resource "azurerm_mssql_server_extended_auditing_policy" "sql_policy" {
  depends_on = [azurerm_mssql_server.sql, data.azurerm_storage_account.sa]

  server_id                               = azurerm_mssql_server.sql.id
  storage_endpoint                        = data.azurerm_storage_account.sa.primary_blob_endpoint
  storage_account_access_key              = data.azurerm_storage_account.sa.primary_access_key
  storage_account_access_key_is_secondary = false
  retention_in_days                       = var.retention_in_days
  # Log analytics: https://github.com/hashicorp/terraform-provider-azurerm/tree/main/examples/sql-azure/sql_auditing_log_analytics
  # Event hub: https://github.com/hashicorp/terraform-provider-azurerm/tree/main/examples/sql-azure/sql_auditing_eventhub
  # Azure Monitor
  log_monitoring_enabled = var.log_monitoring_enabled

  #lifecycle {
  #ignore_changes = []
  #}
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_firewall_rule
resource "azurerm_mssql_firewall_rule" "azure" {
  depends_on = [azurerm_mssql_server.sql]
  count      = var.azureservices_enabled ? 1 : 0

  name             = "AzureServices"
  server_id        = azurerm_mssql_server.sql.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_mssql_firewall_rule" "other" {
  depends_on = [azurerm_mssql_server.sql]
  count      = length(var.firewall_rules)

  name             = var.firewall_rules[count.index].name
  server_id        = azurerm_mssql_server.sql.id
  start_ip_address = var.firewall_rules[count.index].start_ip
  end_ip_address   = var.firewall_rules[count.index].end_ip
}


resource "azurerm_management_lock" "sql_lock" {
  depends_on = [azurerm_mssql_server.sql]
  count      = var.lock_resource ? 1 : 0

  name       = "CanNotDelete"
  scope      = azurerm_mssql_server.sql.id
  lock_level = "CanNotDelete"
  notes      = "Terraform: This prevents accidental deletion of this resource and sub resources."

  lifecycle {
    ignore_changes = [name, notes]
  }
}

resource "azurerm_role_assignment" "sql_identity_on_sa" {
  depends_on = [data.azurerm_storage_account.sa, data.azurerm_mssql_server.sql]

  scope                = data.azurerm_storage_account.sa.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_mssql_server.sql.identity.0.principal_id

  lifecycle {
    ignore_changes = [principal_id, scope]
  }
}

resource "azurerm_storage_container" "container" {
  depends_on = [data.azurerm_storage_account.sa]

  name                  = "sqlsrvalerts"
  storage_account_name  = data.azurerm_storage_account.sa.name
  container_access_type = "private"
}


# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_server_security_alert_policy
resource "azurerm_mssql_server_security_alert_policy" "sql_alert" {
  depends_on = [azurerm_role_assignment.sql_identity_on_sa]

  resource_group_name        = data.azurerm_resource_group.rg.name
  server_name                = azurerm_mssql_server.sql.name
  state                      = var.alert_state
  storage_endpoint           = data.azurerm_storage_account.sa.primary_blob_endpoint
  storage_account_access_key = data.azurerm_storage_account.sa.primary_access_key
  retention_days             = var.retention_in_days
  email_account_admins       = var.email_admins
  email_addresses            = var.email_addresses

  disabled_alerts = [
    "Sql_Injection",
    "Data_Exfiltration"
  ]
}
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_server_vulnerability_assessment
resource "azurerm_mssql_server_vulnerability_assessment" "assess" {
  depends_on = [azurerm_mssql_server_security_alert_policy.sql_alert, azurerm_storage_container.container]

  server_security_alert_policy_id = azurerm_mssql_server_security_alert_policy.sql_alert.id
  storage_container_path          = "${data.azurerm_storage_account.sa.primary_blob_endpoint}${azurerm_storage_container.container.name}/"
  storage_account_access_key      = data.azurerm_storage_account.sa.primary_access_key

  recurring_scans {
    enabled                   = var.alert_state == "Enabled" ? true : false
    email_subscription_admins = var.email_admins
    emails                    = var.email_addresses
  }
}

resource "azurerm_monitor_diagnostic_setting" "mds" {
  depends_on = [azurerm_mssql_server.sql]
  count      = var.law_id == null ? 0 : 1

  name                       = "${var.name}-ds"
  target_resource_id         = "${azurerm_mssql_server.sql.id}/databases/master"
  log_analytics_workspace_id = var.law_id

  log {
    category = "SQLSecurityAuditEvents"
    enabled  = true

    retention_policy {
      enabled = true
      days    = var.retention_in_days
    }
  }

  metric {
    category = "AllMetrics"
    retention_policy {
      enabled = true
      days    = var.retention_in_days
    }
  }

  lifecycle {
    ignore_changes = [log, metric]
  }
}

///////////////////////////////////////////////////////////////////////
//////////// RBAC
resource "azurerm_role_assignment" "role_sql" {
  depends_on = [azurerm_mssql_server.sql]
  count      = var.enable_rbac_authorization ? length(var.rbac_roles) : 0

  scope                = azurerm_mssql_server.sql.id
  role_definition_name = var.rbac_roles[count.index].role_definition_name
  principal_id         = var.rbac_roles[count.index].principal_id
}
