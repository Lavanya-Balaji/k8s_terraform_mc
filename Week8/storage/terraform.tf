resource "azurerm_resource_group" "rg" {
  name     = "rg-storage-demo"
  location = "Central India"
}

resource "azurerm_storage_account" "storage" {
  name                     = "masterclassstg" # must be globally unique
  resource_group_name      = azurerm_resource_group.rg.name # Implicit Dependency (automatic) 
  location                 = azurerm_resource_group.rg.location

  account_tier             = "Standard"   # cheaper than Premium
  account_replication_type = "LRS"        # lowest cost

  account_kind             = "StorageV2"  # recommended
  access_tier              = "Cool"       # cheaper if infrequent access

  min_tls_version          = "TLS1_2"

  tags = {
    environment = "dev"
  }
    depends_on = [azurerm_resource_group.rg]

}

resource "azurerm_storage_container" "container" {
  name                  = "tfstate"   # container name
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-masterclass"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "aksdemo"
  kubernetes_version = "1.35.1" #1.34.4  # specify a supported Kubernetes version
  default_node_pool {
    name       = "nodepool1"
    node_count = 1                     # 👈 only 1 node
    vm_size    = "Standard_D2s_v3"        # 👈 cheap VM (balanced)
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "kubenet"         # 👈 cheaper networking
  }
  oidc_issuer_enabled = true   
  tags = {
    environment = "dev"
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"

  namespace        = "argocd"
  create_namespace = true

  set = [
    {
      name  = "server.service.type"
      value = "ClusterIP"
    }
  ]
}