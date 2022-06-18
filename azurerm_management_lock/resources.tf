resource "azurerm_management_lock" "ml" {
  depends_on = [data.azurerm_resource_group.rg]

  name       = var.name
  scope      = var.scope
  lock_level = var.lock_level
  notes      = var.notes

  lifecycle {
    ignore_changes = [name, notes]
  }
}