output "id" {
  description = "ID of the NAT Gateway."
  value       = azurerm_nat_gateway.natg.id
}

output "natg_public_ip_address_ids" {
  description = " A list of existing Public IP Address resource IDs which the NAT Gateway is using."
  value       = data.azurerm_nat_gateway.natg.public_ip_address_ids
}

output "natg_public_ip_prefix_ids" {
  description = "A list of existing Public IP Prefix resource IDs which the NAT Gateway is using."
  value       = data.azurerm_nat_gateway.natg.public_ip_prefix_ids
}

output "natg_resource_guid" {
  description = "The Resource GUID of the NAT Gateway."
  value       = data.azurerm_nat_gateway.natg.resource_guid
}

output "sku_name" {
  description = "The SKU used by the NAT Gateway."
  value       = data.azurerm_nat_gateway.natg.sku_name
}

output "zones" {
  description = "A list of Availability Zones which the NAT Gateway exists in."
  value       = data.azurerm_nat_gateway.natg.zones
}