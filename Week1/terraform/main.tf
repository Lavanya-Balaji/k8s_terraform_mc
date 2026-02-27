# Terraform  to create kind cluster


terraform {
  required_version = ">= 1.5.0"
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "null_resource" "kind_cluster" {
  provisioner "local-exec" {
    command = <<EOT
      kind create cluster --name my-kind-cluster --config kind-config.yaml
    EOT
  }

  triggers = {
    cluster_name = "my-kind-cluster"
  }
}

# output "kubeconfig" {
#   value = file("~/.kube/config")
# }