# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/firewall
resource "azurerm_firewall" "fw" {
  depends_on = [data.azurerm_subnet.snet_fw, data.azurerm_subnet.snet_mgnt]

  name                = var.name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  sku_name            = var.sku_name
  sku_tier            = var.sku_tier
  dns_servers         = local.dns_servers
  threat_intel_mode   = local.threat_intel_mode
  firewall_policy_id  = var.firewall_policy_id
  tags                = var.tags

  ip_configuration {
    name                 = var.ip_conf_name
    subnet_id            = data.azurerm_subnet.snet_fw.id
    public_ip_address_id = var.pipa_id
  }

  dynamic "management_ip_configuration" {
    for_each = var.pipa_id_mgmt != null ? [1] : []

    content {
      name                 = var.ip_conf_mgt_name
      subnet_id            = data.azurerm_subnet.snet_mgnt[0].id
      public_ip_address_id = var.pipa_id_mgmt
    }
  }
}

resource "azurerm_management_lock" "fw_lock" {
  depends_on = [azurerm_firewall.fw]
  count      = var.lock_resource ? 1 : 0

  name       = "CanNotDelete"
  scope      = azurerm_firewall.fw.id
  lock_level = "CanNotDelete"
  notes      = "Terraform: This prevents accidental deletion if this resource"
}
