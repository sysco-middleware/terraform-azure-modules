# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/nat_gateway
resource "azurerm_nat_gateway" "natg" {
  depends_on = [data.azurerm_resource_group.rg]

  name                    = var.name
  location                = data.azurerm_resource_group.rg.location
  resource_group_name     = data.azurerm_resource_group.rg.name
  sku_name                = var.sku_name
  idle_timeout_in_minutes = var.idle_timeout_in_minutes
  zones                   = var.zones

  # public_ip_address_ids   = [azurerm_public_ip.example.id] # DEPRICATED 
  # public_ip_prefix_ids    = [azurerm_public_ip_prefix.example.id] # DEPRICATED  

  lifecycle {
    ignore_changes = [tags, location]
  }
}

resource "azurerm_subnet_nat_gateway_association" "snatga" {
  depends_on = [azurerm_nat_gateway.natg]
  count      = length(var.snet_names)

  subnet_id      = data.azurerm_subnet.snet[count.index].id
  nat_gateway_id = azurerm_nat_gateway.natg.id

  lifecycle {
    ignore_changes = [subnet_id]
  }
}


resource "azurerm_nat_gateway_public_ip_prefix_association" "natgpipa" {
  depends_on = [azurerm_nat_gateway.natg, data.azurerm_public_ip_prefix.pipp]
  count      = length(var.natgpipa_objects)

  nat_gateway_id      = azurerm_nat_gateway.natg.id
  public_ip_prefix_id = data.azurerm_public_ip_prefix.pipp[count.index].id

  lifecycle {
    ignore_changes = [public_ip_prefix_id]
  }
}

resource "azurerm_nat_gateway_public_ip_association" "natgpiaa" {
  depends_on = [azurerm_nat_gateway.natg, data.azurerm_public_ip.pipa]
  count      = length(var.natgpiaa_objects)

  nat_gateway_id       = azurerm_nat_gateway.natg.id
  public_ip_address_id = data.azurerm_public_ip.pipa[count.index].id

  lifecycle {
    ignore_changes = [public_ip_address_id]
  }
}

resource "azurerm_management_lock" "natg_lock" {
  depends_on = [azurerm_nat_gateway.natg]
  count      = var.lock_resource ? 1 : 0

  name       = "CanNotDelete"
  scope      = azurerm_nat_gateway.natg.id
  lock_level = "CanNotDelete"
  notes      = "Terraform: This prevents accidental deletion of this resource."

  lifecycle {
    ignore_changes = [name, notes]
  }
}


