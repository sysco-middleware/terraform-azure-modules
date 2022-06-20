resource "azurerm_route_table" "rt" {
  depends_on = [data.azurerm_resource_group.rg]

  name                          = var.name
  location                      = data.azurerm_resource_group.rg.location
  resource_group_name           = data.azurerm_resource_group.rg.name
  disable_bgp_route_propagation = var.disable_propagation
  tags                          = var.tags

  dynamic "route" {
    for_each = length(var.routes) > 0 ? var.routes : []
    iterator = each

    content {
      name                   = each.value.name
      address_prefix         = each.value.address_prefix
      next_hop_type          = each.value.next_hop_type
      next_hop_in_ip_address = each.value.next_hop_type == "VirtualAppliance" ? each.value.next_hop_in_ip_address : null
    }
  }

  lifecycle {
    ignore_changes = [tags, location]
  }
}

resource "azurerm_subnet_route_table_association" "srta" {
  depends_on = [azurerm_route_table.rt]
  count      = length(var.subnet_ids)

  subnet_id      = var.subnet_ids[count.index]
  route_table_id = azurerm_route_table.rt.id

  lifecycle {
    ignore_changes = [subnet_id]
  }
}