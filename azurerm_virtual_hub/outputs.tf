output "id" {
  description = "The ID of the Virtual Hub."
  value       = azurerm_virtual_hub.vhub.id
}

output "route_table_id" {
  description = "The ID of the default Route Table in the Virtual Hub."
  value       = azurerm_virtual_hub.vhub.default_route_table_id
}

output "virtual_router_asn" {
  description = "The Autonomous System Number of the Virtual Hub BGP router."
  value       = azurerm_virtual_hub.vhub.virtual_router_asn
}

output "virtual_router_ips" {
  description = "The IP addresses of the Virtual Hub BGP router."
  value       = azurerm_virtual_hub.vhub.virtual_router_ips
}