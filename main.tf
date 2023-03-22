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

