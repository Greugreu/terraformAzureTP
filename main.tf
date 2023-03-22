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
}

resource "azurerm_resource_group" "TPAzureGroup" {
  location = "West Europe"
  name     = "rg-vclarke"
}