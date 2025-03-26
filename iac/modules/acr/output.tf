output "acr_id" {
  value = azurerm_container_registry.acr.id
}

output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}

output "acr_name" {
  value = azurerm_container_registry.acr.name
}

output "username" {
  value = azurerm_container_registry.acr.admin_username
}

output "password" {
  value = azurerm_container_registry.acr.admin_password
}