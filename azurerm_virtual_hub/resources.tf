resource "azurerm_virtual_hub" "vhub" {
  depends_on = [data.azurerm_resource_group.rg]

  name                = var.name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location == null ? data.azurerm_resource_group.rg.location : var.location
  virtual_wan_id      = var.virtual_wan_id
  address_prefix      = var.address_prefix
  sku                 = var.sku
  tags                = var.tags

  dynamic "route" {
    for_each = length(var.routes) > 0 ? var.routes : []
    iterator = each

    content {
      asn         = each.value.address_prefixes
      peer_weight = each.value.next_hop_ip_address
    }
  }
}