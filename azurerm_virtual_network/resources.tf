

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network
resource "azurerm_virtual_network" "vnet" {
  depends_on = [data.azurerm_resource_group.rg]

  name                    = var.name
  resource_group_name     = data.azurerm_resource_group.rg.name
  location                = var.location == null ? data.azurerm_resource_group.rg.location : var.location
  address_space           = var.address_space
  dns_servers             = local.dns_servers
  tags                    = var.tags
  flow_timeout_in_minutes = var.flow_timeout_in_minutes
  #bgp_community           = 12076 # (Optional) The BGP community attribute in format <as-number>:<community-value>.

  dynamic "ddos_protection_plan" {
    for_each = var.ddospp_id != null ? [1] : []
    iterator = each
    content {
      id     = var.ddospp_id
      enable = var.ddospp_enabled
    }
  }

  dynamic "subnet" {
    for_each = length(var.subnets) > 0 ? var.subnets : []
    iterator = each
    content {
      name           = each.value.name
      address_prefix = each.value.address_prefix
      security_group = each.value.security_group_id
    }
  }

  lifecycle {
    ignore_changes = [tags, location]
  }
}

