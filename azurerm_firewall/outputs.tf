output "id" {
  description = "The ID of the Azure Firewall."
  value       = azurerm_firewall.fw.id
}

output "private_ip_address" {
  description = "The Private IP address of the Azure Firewall."
  value       = azurerm_firewall.fw.ip_configuration[0].private_ip_address
}

resource "azurerm_management_lock" "pipa_lock" {
  depends_on = [azurerm_public_ip.pipa]
  count      = var.lock_resource ? 1 : 0

  name       = "CanNotDelete"
  scope      = azurerm_public_ip.pipa.id
  lock_level = "CanNotDelete"
  notes      = "Terraform: This prevents accidental deletion if this resource"
}