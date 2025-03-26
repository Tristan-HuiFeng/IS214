terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.1.0"
    }
  }

   backend "azurerm" {
        resource_group_name  = "tfstate"
        storage_account_name = "tfstatestorageis214"
        container_name       = "tfstate"
        key                  = "terraform.tfstate"
    }
}

provider "azurerm" {
  features {}
  subscription_id   = "edadbcbc-5d10-4546-96ac-c77c475e80a4"
}

resource "azurerm_resource_group" "tfstate" {
  name     = "tfstate"
  location = "East US 2"
}

resource "azurerm_storage_account" "tfstate" {
  name                     = "tfstatestorageis214"
  resource_group_name      = azurerm_resource_group.tfstate.name
  location                 = azurerm_resource_group.tfstate.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_nested_items_to_be_public = false

}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.tfstate.id
  container_access_type = "private"
}
