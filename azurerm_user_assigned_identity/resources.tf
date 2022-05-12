resource "azurerm_user_assigned_identity" "umi" {
  depends_on = [data.azurerm_resource_group.rg]

  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  name                = var.name

  lifecycle {
    ignore_changes = [location]
  }
}

resource "azurerm_management_lock" "umi_lock" {
  depends_on = [azurerm_user_assigned_identity.umi]
  count      = var.lock_resource ? 1 : 0

  name       = "CanNotDelete"
  scope      = azurerm_user_assigned_identity.umi.id
  lock_level = "CanNotDelete"
  notes      = "Terraform: This prevents accidental deletion if this resource and sub resources"
}