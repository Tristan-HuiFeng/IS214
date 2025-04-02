resource "azurerm_resource_group" "rg" {
  name     = "odoo-rg"
  location = "EAST US 2"
}

module "acr" {
  depends_on = [ azurerm_resource_group.rg ]
  source = "./modules/acr"
  resource_group_name = azurerm_resource_group.rg.name
  resource_group_location = azurerm_resource_group.rg.location
}

module "akv" {
  depends_on = [ azurerm_resource_group.rg ]
  source = "./modules/akv"
  resource_group_name = azurerm_resource_group.rg.name
  resource_group_location = azurerm_resource_group.rg.location
}

module "afs" {
  depends_on = [ azurerm_resource_group.rg ]
  source = "./modules/afs"
  resource_group_name = azurerm_resource_group.rg.name
  resource_group_location = azurerm_resource_group.rg.location
  virtual_network_subnet_id = module.vnet.app_subnet_id
}

module "vnet" {
  depends_on = [ azurerm_resource_group.rg ]
  source = "./modules/vnet"
  resource_group_name = azurerm_resource_group.rg.name
  resource_group_location = azurerm_resource_group.rg.location
}


module "aca" {
  depends_on = [ azurerm_resource_group.rg ]
  source = "./modules/aca"
  registry_server      = module.acr.acr_login_server
  acr_id               = module.acr.acr_id
  resource_group_name = azurerm_resource_group.rg.name
  resource_group_location = azurerm_resource_group.rg.location
  acr_username = module.acr.username
  acr_password = module.acr.password
  app_subnet_id = module.vnet.app_subnet_id
  key_vault_id = module.akv.key_vault_id
  storage_account_id = module.afs.storage_account_id
  fileshare_name = module.afs.fileshare_name
  storage_primary_key = module.afs.primary_access_key
  storage_account_name = module.afs.storage_account_name
}

module "adb" {
  depends_on = [ azurerm_resource_group.rg ]
  source = "./modules/adb"
  resource_group_name = azurerm_resource_group.rg.name
  resource_group_location = azurerm_resource_group.rg.location
  db_subnet_id = module.vnet.db_subnet_id
  private_dns_zone_id = module.vnet.db_private_dns_zone_id
  key_vault_id = module.akv.key_vault_id
}

module "migration" {
  source = "./modules/migration"
  resource_group_name = azurerm_resource_group.rg.name
  virutal_network_name = module.vnet.virtual_network_name
  virutal_network_id = module.vnet.virtual_network_id
  db_private_dns_zone_name = module.vnet.db_private_dns_zone_name
}

# module "agw" {
#   source = "./modules/agw"
#   resource_group_name = azurerm_resource_group.rg.name
#   resource_group_location = azurerm_resource_group.rg.location
#   virutal_network_name = module.vnet.virtual_network_name
#   agw_subnet_id = module.vnet.agw_subnet_id
# }