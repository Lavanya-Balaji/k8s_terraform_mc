terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "rg-aks-demo"
  location = "Central India"
}

# AKS Cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-demo-cluster"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "aksdemo"

  default_node_pool {
    name       = "nodepool1"
    node_count = 1                     # 👈 only 1 node (cheapest)
    vm_size    = "Standard_B2s"        # 👈 low-cost VM
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "kubenet"         # 👈 cheaper than Azure CNI
  }

  tags = {
    environment = "dev"
  }
}

# az aks stop --name aks-demo-cluster --resource-group rg-aks-demo 
