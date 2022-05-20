output "id" {
  description = "The ID of the Firewall policy."
  value       = azurerm_firewall_policy.policy.id
}

output "child_policies" {
  description = "A list of reference to child Firewall Policies of this Firewall Policy."
  value       = azurerm_firewall_policy.policy.child_policies
}

output "firewalls" {
  description = "A list of references to Azure Firewalls that this Firewall Policy is associated with."
  value       = azurerm_firewall_policy.policy.firewalls
}

output "sku_tier" {
  description = "The Sku tier."
  value       = azurerm_firewall_policy.policy.sku
}