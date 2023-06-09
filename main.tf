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

###############
# Azure: Resource Group && Service
###############

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

###############
# Azure: WebApp
###############

resource "azurerm_linux_web_app" "AzurermWebApp" {
  name                = "web-${var.projectName}${var.environment_suffix}"
  resource_group_name = azurerm_resource_group.TPAzureGroup.name
  location            = azurerm_resource_group.TPAzureGroup.location
  service_plan_id     = azurerm_service_plan.AzurermServicePlan.id
  site_config {
    application_stack {
      dotnet_version = "6.0"
    }
  }
  
  connection_string {
    name = "DefaultConnection"
    value = "Server=tcp:${azurerm_mssql_server.sql-srv.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.sql-db.name};Persist Security Info=False;User ID=${data.azurerm_key_vault_secret.database-username.value};Password=${data.azurerm_key_vault_secret.database-password.value};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
    type = "SQLAzure"
  }
  
  app_settings = {
    "RabbitMQ__Hostname" = azurerm_container_group.rabbitmq.fqdn,
    "RabbitMQ__Username" = data.azurerm_key_vault_secret.rabbitmq-login.value,
    "RabbitMQ__Password" = data.azurerm_key_vault_secret.rabbitmq-password.value
  }
}

###############
# Azure: Database
###############

resource "azurerm_mssql_server" "sql-srv" {
  name                         = "sqlsrv-${var.projectName}${var.environment_suffix}"
  location                     = data.azurerm_resource_group.rg-vclarke.location
  resource_group_name          = data.azurerm_resource_group.rg-vclarke.name
  version                      = "12.0"
  administrator_login          = data.azurerm_key_vault_secret.database-username.value
  administrator_login_password = data.azurerm_key_vault_secret.database-password.value
}

resource "azurerm_mssql_firewall_rule" "example" {
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.sql-srv.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
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

###############
# RabbitMQ : Container Instance
###############
resource "azurerm_container_group" "rabbitmq" {
  name                = "aci-mq-${var.projectName}${var.environment_suffix}"
  resource_group_name = data.azurerm_resource_group.rg-vclarke.name
  location            = data.azurerm_resource_group.rg-vclarke.location
  ip_address_type     = "Public"
  dns_name_label      = "aci-mq-${var.projectName}${var.environment_suffix}"
  os_type             = "Linux"

  container {
    name   = "rabbitmq"
    image  = "rabbitmq:3-management"
    cpu    = "0.5"
    memory = "1.5"

    ports {
      port     = 5672
      protocol = "TCP"
    }

    ports {
      port     = 15672
      protocol = "TCP"
    }

    environment_variables = {
      "RABBITMQ_DEFAULT_USER" = data.azurerm_key_vault_secret.rabbitmq-login.value,
      "RABBITMQ_DEFAULT_PASS" = data.azurerm_key_vault_secret.rabbitmq-password.value
    }
  }
}

###############
# RabbitMQ Console: Container Instance
###############
resource "azurerm_container_group" "console" {
  name                = "aci-console-${var.projectName}${var.environment_suffix}"
  resource_group_name = data.azurerm_resource_group.rg-vclarke.name
  location            = data.azurerm_resource_group.rg-vclarke.location
  ip_address_type     = "None"
  dns_name_label      = "aci-console-${var.projectName}${var.environment_suffix}"
  os_type             = "Linux"
  exposed_port        = []

  container {
    name   = "console"
    image  = "greugreu/pubsub-console:1.0"
    cpu    = "0.5"
    memory = "1.5"

    environment_variables = {
      "RabbitMQ__Hostname" = azurerm_container_group.rabbitmq.fqdn,
      "RabbitMQ__Username" = data.azurerm_key_vault_secret.rabbitmq-login.value,
      "RabbitMQ__Password" = data.azurerm_key_vault_secret.rabbitmq-password.value
    }
  }
}