resource "azurerm_container_registry" "acr" {
  name                = "odooimage"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  sku                 = "Basic"
  admin_enabled       = true
}
