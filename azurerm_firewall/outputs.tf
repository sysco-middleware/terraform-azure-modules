output "id" {
  description = "The ID of the Azure Firewall."
  value       = azurerm_firewall.fw.id
}

output "private_ip_address" {
  description = "The Private IP address of the Azure Firewall."
  value       = azurerm_firewall.fw.ip_configuration[0].private_ip_address
}
