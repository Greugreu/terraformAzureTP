terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.48.0"
    }
  }

  backend "azurerm" {
    
  }
}

provider "azurerm" {
  # configuration options
  features {}
}

resource "azurerm_resource_group" "TPAzureGroup" {
  location = var.location
  name     = "rg-${var.projectName}${var.environment_suffix}"
}

resource "azurerm_service_plan" "AzurermServicePlan" {
  name                = "${var.projectName}${var.environment_suffix}-Plan"
  resource_group_name = azurerm_resource_group.TPAzureGroup.name
  location            = azurerm_resource_group.TPAzureGroup.location
  os_type             = "Linux"
  sku_name            = "P1v2"
}

resource "azurerm_linux_web_app" "AzurermWebApp" {
  name                = "web-${var.projectName}${var.environment_suffix}"
  resource_group_name = azurerm_resource_group.TPAzureGroup.name
  location            = azurerm_resource_group.TPAzureGroup.location
  service_plan_id     = azurerm_service_plan.AzurermServicePlan.id
  site_config {}
}

resource "azurerm_mssql_server" "sql-srv" {
  name                         = "sqlsrv-${var.projectName}${var.environment_suffix}"
  location                     = data.azurerm_resource_group.rg-vclarke.location
  resource_group_name          = data.azurerm_resource_group.rg-vclarke.name
  version                      = "12.0"
  administrator_login          = data.azurerm_key_vault.kv.database-login.value
  administrator_login_password = data.azurerm_key_vault.kv.database-password.value
}

resource "azurerm_mssql_database" "sql-db" {
  name           = "RabbitMqDemo"
  server_id      = azurerm_mssql_server.sql-srv.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 2
  read_scale     = false
  sku_name       = "S0"
  zone_redundant = false
}
