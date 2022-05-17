
data "azurerm_resource_group" "rg" {
  name = var.rg_name
}

data "azurerm_virtual_network" "vnet" {
  depends_on = [data.azurerm_resource_group.rg]

  name                = var.vnet_name
  resource_group_name = var.rg_name
}

data "azurerm_subnet" "snet_fw" {
  depends_on = [data.azurerm_resource_group.rg]

  name                 = var.snet_fw_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.rg_name
}

data "azurerm_subnet" "snet_mgnt" {
  depends_on = [data.azurerm_resource_group.rg]
  count = var.pipa_id_mgmt |= null ? 1 : 0

  name                 = var.snet_mgnt_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.rg_name
}


data "azurerm_firewall" "fw" {
  depends_on = [azurerm_firewall.fw]

  name                = var.name
  resource_group_name = var.rg_name
}
