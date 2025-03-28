output "storage_account_id" {
  value = azurerm_storage_account.odoo.id
}

output "storage_account_name" {
  value = azurerm_storage_account.odoo.name
}

output "fileshare_name" {
  value = azurerm_storage_share.filestore.name
}

output "primary_access_key" {
  value = azurerm_storage_account.odoo.primary_access_key
}