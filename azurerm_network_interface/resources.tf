# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface
resource "azurerm_network_interface" "nic" {
  depends_on = [data.azurerm_resource_group.rg]

  name                          = var.name
  resource_group_name           = data.azurerm_resource_group.rg.name
  location                      = data.azurerm_resource_group.rg.location
  dns_servers                   = var.dns_servers
  enable_ip_forwarding          = var.enable_ip_forwarding
  enable_accelerated_networking = var.enable_accelerated_networking
  internal_dns_name_label       = var.internal_dns_name_label
  tags                          = var.tags

  dynamic "ip_configuration" {
    for_each = length(var.ip_configurations) > 0 ? var.ip_configurations : []
    iterator = each

    content {
      name                          = each.value.name
      subnet_id                     = each.value.subnet_id # When private_ip_address_version is IPv4. (Required) The ID of the Subnet where this Network Interface should be located in.
      private_ip_address_version    = "IPv4"
      private_ip_address            = each.value.private_ip_address
      primary                       = each.value.primary                   # Must be true for the first
      private_ip_address_allocation = each.value.private_ipaddr_allocation # Dynamic or Static. Private IP address is required when privateIPAllocationMethod is Static in IP configuration
    }
  }
}

resource "azurerm_network_interface_security_group_association" "nsg_assoc" {
  depends_on = [azurerm_network_interface.nic, data.azurerm_network_security_group.nsg]

  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = data.azurerm_network_security_group.nsg.id
}

resource "azurerm_management_lock" "kv_lock" {
  depends_on = [azurerm_network_interface.nic]
  count      = var.lock_resource ? 1 : 0

  name       = "CanNotDelete"
  scope      = azurerm_network_interface.nic.id
  lock_level = "CanNotDelete"
  notes      = "Terraform: This prevents accidental deletion of this resource."

  lifecycle {
    ignore_changes = [name, notes]
  }
}
