resource "azurerm_storage_account" "odoo" {
  name                     = "odoostorageis214"
  resource_group_name      = var.resource_group_name
  location                 = var.resource_group_location
  account_tier             = "Premium"
  account_replication_type = "ZRS"
  account_kind = "FileStorage"

  network_rules {
    default_action = "Deny"
    virtual_network_subnet_ids = [var.virtual_network_subnet_id, "/subscriptions/1bf92fb1-f19a-4b1a-9304-9ceaad733c5c/resourceGroups/E07G10T04-RG/providers/Microsoft.Network/virtualNetworks/E07G10T04-VM-vnet/subnets/default"]
  }
}

resource "azurerm_storage_share" "filestore" {
  name                 = "odoo-smb"
  storage_account_id  = azurerm_storage_account.odoo.id
  quota                = 100
  access_tier = "Premium"

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

