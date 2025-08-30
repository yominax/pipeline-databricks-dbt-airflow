output "adls_access_key" {
  value       = azurerm_storage_account.adls.primary_access_key
  sensitive   = true
}

output "bronze_container_name" {
  value = azurerm_storage_container.containers["bronze"].name
}

output "silver_container_name" {
  value = azurerm_storage_container.containers["silver"].name
}

output "gold_container_name" {
  value = azurerm_storage_container.containers["gold"].name
}

# output "key_vault_id" {
#   value = azurerm_key_vault.kv.id
# }

# output "adf_managed_identity_object_id" {
#   value       = azurerm_data_factory.adf.identity[0].principal_id
# }