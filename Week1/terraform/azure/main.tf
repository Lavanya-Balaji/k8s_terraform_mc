terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.62.0"
    }
  }
}

provider "azurerm" {
  # Configuration options

    subscription_id = "00000000-0000-0000-0000-000000000000"
  client_id       = "00000000-0000-0000-0000-000000000000"
  use_oidc        = true

  # for GitHub Actions or Azure DevOps Pipelines
  oidc_request_token = var.oidc_request_token
  oidc_request_url   = var.oidc_request_url

  # for Azure DevOps Pipelines
  ado_pipeline_service_connection_id = var.ado_pipeline_service_connection_id

  # for other generic OIDC providers, providing token directly
  oidc_token = var.oidc_token

  # for other generic OIDC providers, reading token from a file
  oidc_token_file_path = var.oidc_token_file_path

  tenant_id = "00000000-0000-0000-0000-000000000000"
}

resource "azurerm_resource_group" "example" {
  name     = "week1-rg"
  location = "Central India"
}

resource "azurerm_storage_account" "example" {
  name                     = "week1storageacct"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = "staging"
  }
}