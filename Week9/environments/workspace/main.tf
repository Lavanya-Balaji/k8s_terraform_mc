provider "azurerm" {
  features {}
}

# -------------------
# Resource Group
# -------------------
module "rg" {
  source   = "../../modules/rg"
  name     = var.rg_name
  location = var.location
}

# -------------------
# Storage Account
# -------------------
module "storage" {
  source   = "../../modules/storage"
  name     = var.storage_name
  rg_name  = module.rg.name
  location = module.rg.location
}

# -------------------
# AKS Cluster
# -------------------
module "aks" {
  source   = "../../modules/aks"
  name     = var.aks_name
  rg_name  = module.rg.name
  location = module.rg.location
}

# -------------------
# ArgoCD
# -------------------
module "argocd" {
  source = "../../modules/argocd"

  host                   = module.aks.kube_config[0].host
  client_certificate     = module.aks.kube_config[0].client_certificate
  client_key             = module.aks.kube_config[0].client_key
  cluster_ca_certificate = module.aks.kube_config[0].cluster_ca_certificate
}