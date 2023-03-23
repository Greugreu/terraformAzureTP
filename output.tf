output "main-rg-name" {
  value = azurerm_resource_group.TPAzureGroup.name
}
output "main-rg-id" {
  value = azurerm_resource_group.TPAzureGroup.id
}

output "database-username" {
  value     = data.azurerm_key_vault_secret.database-username.value
  sensitive = true
}

output "database-password" {
  value     = data.azurerm_key_vault_secret.database-password.value
  sensitive = true
}

