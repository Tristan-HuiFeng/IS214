data "azurerm_key_vault_secret" "db_user" {
  name         = "db-user"
  key_vault_id = var.key_vault_id
}

data "azurerm_key_vault_secret" "db_password" {
  name         = "odoo-password"
  key_vault_id = var.key_vault_id
}

resource "azurerm_postgresql_flexible_server" "odoo" {
  name                   = "odoodb-is214"
  resource_group_name    = var.resource_group_name
  location               = var.resource_group_location
  version                = "16"
  delegated_subnet_id    = var.db_subnet_id
  private_dns_zone_id    = var.private_dns_zone_id
  administrator_login    = data.azurerm_key_vault_secret.db_user.value
  administrator_password = data.azurerm_key_vault_secret.db_password.value
  zone                   = "1"
  storage_mb             = 32768
  sku_name               = "B_Standard_B1ms"
  backup_retention_days  = 7
  public_network_access_enabled = false

}

resource "azurerm_postgresql_flexible_server_database" "odoo" {
  name      = "is214main"
  server_id = azurerm_postgresql_flexible_server.odoo.id
  collation = "en_US.utf8"
  charset   = "utf8"

}