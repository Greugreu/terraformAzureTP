terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.48.0"
    }
  }
}

provider "azurerm" {
  # configuration options
  features {}
}

resource "azurerm_resource_group" "TPAzureGroup" {
  location = "West Europe"
  name     = "rg-vclarke${var.environment_suffix}"
}

resource "azurerm_service_plan" "AzurermServicePlan" {
  name                = "exmaple-network"
  resource_group_name = azurerm_resource_group.rg-vclarke.name
  location            = azurerm_resource_group.rg_vclarke.location
  os_type             = "Linux"
  sku_name            = "P1v2"
}