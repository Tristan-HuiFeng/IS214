output "db_subnet_id" {
  value = azurerm_subnet.db.id
}

output "db_private_dns_zone_id" {
  value = azurerm_private_dns_zone.db.id
}

output "db_private_dns_zone_name" {
  value = azurerm_private_dns_zone.db.name
}

output "app_subnet_id" {
  value = azurerm_subnet.app.id
}

output "agw_subnet_id" {
  value = azurerm_subnet.agw.id
}

output "virtual_network_name" {
  value = azurerm_virtual_network.odoo.name
}

output "virtual_network_id" {
  value = azurerm_virtual_network.odoo.id
}