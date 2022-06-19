resource "azurerm_route_table" "example" {
  depends_on = [data.azurerm_resource_group.rg]

  name                          = var.name
  location                      = data.azurerm_resource_group.example.location
  resource_group_name           = data.azurerm_resource_group.example.name
  disable_bgp_route_propagation = var.disable_propagation

  dynamic "route" {
    for_each = length(var.routes) > 0 ? var.routes : []
    iterator = each

    content {
      name                   = each.value.name
      address_prefix         = each.value.address_prefix
      next_hop_type          = each.value.next_hop_type
      next_hop_in_ip_address = each.value.next_hop_in_ip_address
    }
  }

  lifecycle {
    ignore_changes = [tags, location]
  }
}