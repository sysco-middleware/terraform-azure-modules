output "ids" {
  value = [for item in data.azurerm_subnet.snet : item.id]
}
output "address_prefixes" {
  value = [for item in data.azurerm_subnet.snet : item.address_prefixes]
}
output "network_security_group_ids" {
  value = [for item in data.azurerm_subnet.snet : item.network_security_group_id]
}
