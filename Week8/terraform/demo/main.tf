# locals {
#   container_names = toset([
#     "tfstate4",
#     "tfstateversion5",
#     "tfstateversion6"
#   ])
#   container_count = length(local.container_names)
# }

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
    team        = "devops"
    test = "delete"
    costcenter = "12345" # finnance -> HR 
  }
#versioning_enabled = true

  blob_properties {
    versioning_enabled = true

    delete_retention_policy {
      days = 7
    }
  }

#   lifecycle {
#   prevent_destroy = true
#   #ignore_changes  = [tags]
# }
}

# resource "azurerm_storage_account" "storage1" {
#   #name = 'INVALID-name@'
#   name                     = lower(replace("MasterClassnew-STG", "-", ""))
#   resource_group_name      = azurerm_resource_group.rg.name # Implicit Dependency (automatic) 
#   location                 = azurerm_resource_group.rg.location

#   account_tier             = "Standard"   # cheaper than Premium
#   account_replication_type = "LRS"        # lowest cost

#   account_kind             = "StorageV2"  # recommended
#   access_tier              = "Cool"       # cheaper if infrequent access

#   min_tls_version          = "TLS1_2"

#   tags = {
#     environment = "dev"
#     team        = "devops"
#   }
# #versioning_enabled = true

#   blob_properties {
#     versioning_enabled = true

#     delete_retention_policy {
#       days = 7
#     }
#   }

#   lifecycle {
#   #prevent_destroy = true
#   ignore_changes  = [tags]
# }
# }


resource "azurerm_storage_container" "container" {
  name                  = "tfstate"   # container name
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "container1" {
  name                  = "tfstateversion1"   # container name
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}
resource "azurerm_storage_container" "container2" {
  name                  = "tfstateversion3"   # container name
  storage_account_name  = azurerm_storage_account.storage.name # Implict dependency
  container_access_type = "private"


#   lifecycle {
#   prevent_destroy = true
# }

}
resource "azurerm_storage_container" "container01" {
  name                  = "tfstateversion01"   # container name
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}

# resource "null_resource" "validate_containers" {
#   count = length(local.container_names) == 0 ? 1 : 0

#   provisioner "local-exec" {
#     command = "echo 'ERROR: At least one container required' && exit 1"
#   }
# }

# resource "azurerm_storage_container" "containers" {
#   for_each = length(local.container_names) > 0 ? local.container_names : toset([])
#   name                  = each.value
#   storage_account_name  = azurerm_storage_account.storage.name
#   container_access_type = "private"
# }

# output "container_count" {
#   value = local.container_count
# }
# resource "azurerm_kubernetes_cluster" "aks" {
#   name                = "aks-masterclass"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
#   dns_prefix          = "aksdemo"
#   kubernetes_version = "1.34.4" #1.34.4  # specify a supported Kubernetes version
#   default_node_pool {
#     name       = "nodepool1"
#     node_count = 1                     # 👈 only 1 node
#     vm_size    = "Standard_D2s_v3"        # 👈 cheap VM (balanced)
#   }

#   identity {
#     type = "SystemAssigned"
#   }

#   network_profile {
#     network_plugin = "kubenet"         # 👈 cheaper networking
#   }
#   oidc_issuer_enabled = true   
#   tags = {
#     environment = "dev"
#   }
# }

# resource "helm_release" "argocd" {
#   name       = "argocd"
#   repository = "https://argoproj.github.io/argo-helm"
#   chart      = "argo-cd"

#   namespace        = "argocd"
#   create_namespace = true

#   set = [
#     {
#       name  = "server.service.type"
#       value = "ClusterIP"
#     }
#   ]
# }

