# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_wan
resource "azurerm_virtual_wan" "vwan" {
  depends_on = [data.azurerm_resource_group.rg]

  name                              = var.name
  resource_group_name               = data.azurerm_resource_group.rg.name
  location                          = var.location == null ? data.azurerm_resource_group.rg.location : var.location
  disable_vpn_encryption            = var.disable_vpn_encryption
  allow_branch_to_branch_traffic    = var.allow_branch_to_branch_traffic
  type                              = var.type
  office365_local_breakout_category = var.o365_category
  tags                              = var.tags
}