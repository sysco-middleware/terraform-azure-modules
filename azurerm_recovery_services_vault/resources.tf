resource "azurerm_recovery_services_vault" "rsv" {
  name                = var.name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  sku                 = var.sku

  soft_delete_enabled = var.soft_delete_enabled
}

resource "azurerm_backup_policy_file_share" "policy" {
  name                = "${var.name}-policy"
  resource_group_name = data.azurerm_resource_group.rg.name
  recovery_vault_name = azurerm_recovery_services_vault.rsv.name

  timezone = "W. Europe Standard Time"

  backup {
    frequency = "Daily"
    time      = "23:00"
  }

  retention_daily {
    count = 30
  }
}
