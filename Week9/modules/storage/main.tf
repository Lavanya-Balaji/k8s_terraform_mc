resource "azurerm_storage_account" "storage" {
  name                     = var.name
  resource_group_name      = var.rg_name
  location                 = var.location

  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  access_tier              = "Cool"
}

resource "azurerm_storage_container" "container" {
  name                  = "tfstate"
  #storage_account_name  = azurerm_storage_account.storage.name
  storage_account_id = azurerm_storage_account.storage.id
  container_access_type = "private"
}