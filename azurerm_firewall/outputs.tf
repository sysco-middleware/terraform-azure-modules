output "id" {
  description = "The ID of the Azure Firewall."
  value       = azurerm_firewall.fw.id
}

output "private_ip_address" {
  description = "The Private IP address of the Azure Firewall."
  value       = azurerm_firewall.fw.ip_configuration[0].private_ip_address
}

### POLICY
/*
output "policy_id" {
  description = "The ID of the Azure Firewall Policy."
  value       = azurerm_firewall_policy.policy.id
}
output "child_policies" {
  description = " A list of reference to child Firewall Policies of this Firewall Policy."
  value       = azurerm_firewall_policy.policy.child_policies
}
output "policy_firewalls" {
  description = "A list of references to Azure Firewalls that this Firewall Policy is associated with."
  value       = azurerm_firewall_policy.policy.firewalls
}
*/