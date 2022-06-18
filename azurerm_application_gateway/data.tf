data "azurerm_resource_group" "rg" {
  name = var.rg_name
}

data "azurerm_user_assigned_identity" "uai" {
  depends_on = [azurerm_user_assigned_identity.uai]

  name                = local.uai_name
  resource_group_name = var.rg_name
}
