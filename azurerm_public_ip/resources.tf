resource "azurerm_public_ip" "pipa" {
  depends_on = [data.azurerm_resource_group.rg, data.azurerm_public_ip_prefix.pipp]

  name                    = var.name
  resource_group_name     = data.azurerm_resource_group.rg.name
  location                = data.azurerm_resource_group.rg.location
  allocation_method       = local.allocation_method
  sku                     = local.sku
  sku_tier                = var.sku_tier
  ip_version              = var.ip_version
  idle_timeout_in_minutes = var.idle_timeout_in_minutes
  domain_name_label       = var.domain_name_label
  public_ip_prefix_id     = var.pipp_name == null ? null : data.azurerm_public_ip_prefix.pipp[0].id
  zones                   = local.zones
  reverse_fqdn            = var.reverse_fqdn
  edge_zone               = var.edge_zone
  ip_tags                 = var.ip_tags
  tags                    = var.tags

  lifecycle {
    ignore_changes = [tags["updated_date"], location, zones]
  }
}

resource "azurerm_management_lock" "pipa_lock" {
  depends_on = [azurerm_public_ip.pipa]
  count      = var.lock_resource ? 1 : 0

  name       = "CanNotDelete"
  scope      = azurerm_public_ip.pipa.id
  lock_level = "CanNotDelete"
  notes      = "Terraform: This prevents accidental deletion of this resource."
}
