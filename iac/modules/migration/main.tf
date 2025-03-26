provider "azurerm" {
  features {}
  alias = "sub2"
  subscription_id = "1bf92fb1-f19a-4b1a-9304-9ceaad733c5c"
}

data "azurerm_virtual_network" "vm_vnet" {
  name                = "E07G10T04-VM-vnet"
  resource_group_name = "E07G10T04-RG"
  provider = azurerm.sub2
}

resource "azurerm_virtual_network_peering" "db_to_vm_peering" {
  name                         = "db-to-vm-peering"
  resource_group_name          = var.resource_group_name
  virtual_network_name         = var.virutal_network_name
  remote_virtual_network_id    = data.azurerm_virtual_network.vm_vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

resource "azurerm_virtual_network_peering" "vm_to_db_peering" {
  name                         = "vm-to-db-peering"
  resource_group_name          = data.azurerm_virtual_network.vm_vnet.resource_group_name
  virtual_network_name         = data.azurerm_virtual_network.vm_vnet.name
  remote_virtual_network_id    = var.virutal_network_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false

  provider = azurerm.sub2
}

resource "azurerm_private_dns_zone_virtual_network_link" "vm_dns_link" {
  name                  = "migration-link"
  private_dns_zone_name = var.db_private_dns_zone_name
  virtual_network_id    = data.azurerm_virtual_network.vm_vnet.id
  resource_group_name   = var.resource_group_name
}
