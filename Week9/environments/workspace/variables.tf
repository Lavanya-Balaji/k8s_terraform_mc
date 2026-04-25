variable "rg_name" {
  type        = string
  description = "Resource Group name"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "storage_name" {
  type        = string
  description = "Storage account name"
}

variable "aks_name" {
  type        = string
  description = "AKS cluster name"
}