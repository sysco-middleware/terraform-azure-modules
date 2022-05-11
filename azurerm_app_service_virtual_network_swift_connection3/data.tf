data "azurerm_client_config" "current" {}

###################################################
############### WEB APP

data "azurerm_windows_web_app" "win_wa" {
  count = length(local.asvnsc_win_apps_wa)

  name                = local.asvnsc_win_apps_wa[count.index].name
  resource_group_name = local.asvnsc_win_apps_wa[count.index].rg_name
}

data "azurerm_linux_web_app" "lin_wa" {
  count = length(local.asvnsc_lin_apps_wa)

  name                = local.asvnsc_lin_apps_wa[count.index].name
  resource_group_name = local.asvnsc_lin_apps_wa[count.index].rg_name
}

###################################################
############### FUNCTION APP

data "azurerm_windows_function_app" "win_fa" {
  count = length(local.asvnsc_win_apps_fa)

  name                = local.asvnsc_win_apps_fa[count.index].name
  resource_group_name = local.asvnsc_win_apps_fa[count.index].rg_name
}

data "azurerm_linux_function_app" "lin_fa" {
  count = length(local.asvnsc_lin_apps_fa)

  name                = local.asvnsc_lin_apps_fa[count.index].name
  resource_group_name = local.asvnsc_lin_apps_fa[count.index].rg_name
}

###################################################
############### SUBNET for asvnsc

data "azurerm_resource_group" "asvnsc_snet_rg" {
  name = var.asvnsc_snet_rg_name
}

data "azurerm_subnet" "asvnsc_snet_wa" {
  depends_on = [data.azurerm_resource_group.asvnsc_snet_rg]
  count      = var.asvnsc_snet_name_wa == null ? 0 : 1 

  name                 = var.asvnsc_snet_name_wa
  virtual_network_name = var.asvnsc_snet_vnet_name
  resource_group_name  = var.asvnsc_snet_rg_name
}

data "azurerm_subnet" "asvnsc_snet_fa" {
  depends_on = [data.azurerm_resource_group.asvnsc_snet_rg]
  count      = var.asvnsc_snet_name_fa == null ? 0 : 1

  name                 = var.asvnsc_snet_name_fa
  virtual_network_name = var.asvnsc_snet_vnet_name
  resource_group_name  = var.asvnsc_snet_rg_name
}

###################################################
############### SQL

data "azurerm_resource_group" "sql_rg" {
  count = length(var.mssqlvn_rules)

  name = var.mssqlvn_rules[count.index].rg_name
}

data "azurerm_mssql_server" "sql" {
  depends_on = [data.azurerm_resource_group.sql_rg]
  count      = length(var.mssqlvn_rules)

  name                = var.mssqlvn_rules[count.index].sql_name
  resource_group_name = var.mssqlvn_rules[count.index].rg_name
}

###################################################
############### SUBNET for SQL

data "azurerm_resource_group" "mssqlvn_snet_rg" {
  count = var.mssqlvn_snet_rg_name == null ? 0 : 1

  name = var.mssqlvn_snet_rg_name
}
data "azurerm_subnet" "mssqlvn_snet" {
  depends_on = [data.azurerm_resource_group.mssqlvn_snet_rg]
  count      = var.mssqlvn_snet_rg_name == null ? 0 : 1

  name                 = var.mssqlvn_snet_name
  virtual_network_name = var.mssqlvn_snet_vnet_name
  resource_group_name  = var.mssqlvn_snet_rg_name
}
