data "azurerm_resource_group" "rg-vclarke" {
  name = "rg-${var.projectName}${var.environment_suffix}"
}
