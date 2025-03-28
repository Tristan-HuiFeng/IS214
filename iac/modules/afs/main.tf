resource "azurerm_storage_account" "odoo" {
  name                     = "odoostorageis214"
  resource_group_name      = var.resource_group_name
  location                 = var.resource_group_location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "filestore" {
  name                 = "odoo-fileshare-is214"
  storage_account_id  = azurerm_storage_account.odoo.id
  quota                = 50

  acl {
    id = "fsodooacl"

    access_policy {
      permissions = "rwdl"
    }
  }
}

# resource "azurerm_user_assigned_identity" "example" {
#   name                = "myidentity"
#   resource_group_name = azurerm_resource_group.example.name
#   location            = azurerm_resource_group.example.location
# }

