output "id" {
  description = "The Public IP Prefix ID."
  value       = azurerm_public_ip_prefix.pipp.id
}

output "ip_prefix" {
  description = "The IP address prefix value that was allocated."
  value       = azurerm_public_ip_prefix.pipp.ip_prefix
}
