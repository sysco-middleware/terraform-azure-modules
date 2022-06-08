output "name" {
  description = "key vault name"
  value       = var.name
}

output "id" {
  description = "key vault id"
  value       = azurerm_key_vault.kv.id
}

output "sku" {
  description = "Sku name"
  value       = azurerm_key_vault.kv.sku_name
}

output "url" {
  description = "key vault url"
  value       = azurerm_key_vault.kv.vault_uri
}

output "key_ids" {
  description = "key vault key ids"
  value       = [for item in azurerm_key_vault_key.key : item.id]
}

output "secret_ids" {
  description = "key vault key secrets"
  value       = [for item in azurerm_key_vault_secret.secret : item.id]
}