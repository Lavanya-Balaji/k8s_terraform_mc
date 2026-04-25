module "rg" {
  source   = "../../modules/rg"
  name     = "rg-storage-demo"
  location = "Central India"
}

module "storage" {
  source   = "../../modules/storage"
  name     = "masterclassstg"
  rg_name  = module.rg.name
  location = module.rg.location
}

module "aks" {
  source   = "../../modules/aks"
  name     = "aks-masterclass"
  rg_name  = module.rg.name
  location = module.rg.location
}

module "argocd" {
  source = "../../modules/argocd"

  host                   = module.aks.kube_config[0].host
  client_certificate     = module.aks.kube_config[0].client_certificate
  client_key             = module.aks.kube_config[0].client_key
  cluster_ca_certificate = module.aks.kube_config[0].cluster_ca_certificate
}

provider "azurerm" {
  features {}
}
