# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip_prefix
resource "azurerm_public_ip_prefix" "pipp" {
  depends_on = [data.azurerm_resource_group.rg]

  name                = var.name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  prefix_length       = var.prefix_length
  sku                 = var.sku
  zones               = local.zones
  ip_version          = var.ip_version
  tags                = var.tags

  lifecycle {
    ignore_changes = [tags, location, ip_version, zones]
  }
}

resource "azurerm_management_lock" "pipp_lock" {
  depends_on = [azurerm_public_ip_prefix.pipp]
  count      = var.lock_resource ? 1 : 0

  name       = "CanNotDelete"
  scope      = azurerm_public_ip_prefix.pipp.id
  lock_level = "CanNotDelete"
  notes      = "Terraform: This prevents accidental deletion if this resource"
}
