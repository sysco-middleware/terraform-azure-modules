# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint
resource "azurerm_private_endpoint" "pe" {
  depends_on = [data.azurerm_resource_group.rg]

  name                = var.name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  subnet_id           = var.subnet_id
  tags                = var.tags

  private_dns_zone_group {
    name                 = var.pdzg_name
    private_dns_zone_ids = var.pdzg_list
  }

  private_service_connection {
    name                              = local.psc_name
    is_manual_connection              = var.psc_ismanual
    private_connection_resource_id    = local.psc_pcr_id
    private_connection_resource_alias = local.psc_pcr_alias
    subresource_names                 = var.psc_subresource_names
    request_message                   = local.psc_request_message
  }
}