# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/vpn_gateway
resource "azurerm_vpn_gateway" "vgtw" {
  depends_on = [data.azurerm_resource_group.rg]

  name                = var.name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location == null ? data.azurerm_resource_group.rg.location : var.location
  virtual_hub_id      = var.virtual_hub_id
  routing_preference  = var.routing
  scale_unit          = var.scale_unit
  tags                = var.tags

  dynamic "bgp_settings" {
    for_each = var.bgp_route_translation_for_nat_enabled ? [1] : []

    content {
      asn         = var.bgp_settings.asn
      peer_weight = var.bgp_settings.peer_weight
      instance_0_bgp_peering_address = {
        custom_ips = var.bgp_settings.instance_0_custom_ips
      }
      instance_1_bgp_peering_address = {
        custom_ips = var.bgp_settings.instance_1_custom_ips
      }
    }
  }
}