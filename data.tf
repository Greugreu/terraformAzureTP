data "azurerm_resource_group" "rg-vclarke" {
  name = "rg-${var.projectName}${var.environment_suffix}"
}

data "azurerm_key_vault" "kv" {
  name                = "kv-${var.projectName}${var.environment_suffix}"
  resource_group_name = data.azurerm_resource_group.rg-vclarke.name
}

data "azurerm_key_vault_secret" "database-username" {
  key_vault_id = data.azurerm_key_vault.kv.id
  name         = "database-username"
}

data "azurerm_key_vault_secret" "database-password" {
  key_vault_id = data.azurerm_key_vault.kv.id
  name         = "database-password"
}

data "azurerm_key_vault_secret" "rabbitmq-login" {
  name = "rabbitmq-login"
  key_vault_id = data.azurerm_key_vault.kv.id
}

data "azurerm_key_vault_secret" "rabbitmq-password" {
  name = "rabbitmq-password"
  key_vault_id = data.azurerm_key_vault.kv.id
}