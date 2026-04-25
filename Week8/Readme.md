### Create Azure Free trial subscription: 
https://azure.microsoft.com/free

### Install Azure CLI: 

Windows:
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
az version

MAC:
brew update
brew install azure-cli
az version

### Install Terraform 


## Login to Azure 

az login 

## Other usefull commands 

az account show
az group list
az storage account list


## providers configuration 

cd storage 
terraform init 
terraform plan 

## Upgrade k8s Pre-reqs
https://learn.microsoft.com/en-us/azure/aks/supported-kubernetes-versions?tabs=azure-cli

https://github.com/Azure/AKS/releases

Authentication ✅
Initialization ✅
Planning ✅

az account set --subscription d3ba1447-b7b7-4a2c-bf25-b854d4db7a53
az aks get-credentials --resource-group rg-storage-demo --name aks-masterclass --overwrite-existing
kubectl get deployments --all-namespaces=true


terraform apply -target=azurerm_kubernetes_cluster.aks


## Terraform import: 

terraform import azurerm_kubernetes_cluster.aks \
/subscriptions/<sub-id>/resourceGroups/rg-storage-demo/providers/Microsoft.ContainerService/managedClusters/aks-masterclass



## For AWS: 

provider "aws" {
  region = "ap-south-1"
}

aws configure --profile dev
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = "ap-south-1"
  profile = "dev"
}
provider "aws" {
  alias   = "dev"
  profile = "dev"
  region  = "ap-south-1"
}

provider "aws" {
  alias   = "prod"
  profile = "prod"
  region  = "ap-south-1"
}
aws configure


provider "aws" {
  region = "ap-south-1"
}

resource "aws_s3_bucket" "tf_state" {
  bucket = "my-tf-state-demo-12345"   # must be globally unique

  tags = {
    Name        = "Terraform State"
    Environment = "dev"
  }
}

terraform init
terraform apply
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.tf_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

👉 Protects your state history

terraform {
  backend "s3" {
    bucket = "my-tf-state-demo-12345"
    key    = "dev/terraform.tfstate"
    region = "ap-south-1"
  }
}

Re-initialize

terraform init
Best Practice (VERY important)

Add state locking using DynamoDB 👇

📄 Add this in bootstrap

resource "aws_dynamodb_table" "tf_lock" {
  name         = "terraform-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

terraform {
  backend "s3" {
    bucket         = "my-tf-state-demo-12345"
    key            = "dev/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-lock"
  }
}


n AWS:

You must configure locking + versioning manually

👉 In Azure:

Locking is built-in automatically
Versioning is optional (not enabled by default)

For Azure : 
  blob_properties {
    versioning_enabled = true
  }

terraform destroy -> state is deleted 

Count Concept:

resource "aws_instance" "vm" {
  count         = 3
  ami           = "ami-12345678"
  instance_type = "t2.micro"
}

aws_instance.vm[0]
aws_instance.vm[1]
aws_instance.vm[2]

resource "azurerm_storage_container" "container" {
  count                 = 3
  name                  = "container-${count.index}"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}


resource "aws_s3_bucket" "bucket" {
  for_each = {
    dev  = "dev-bucket"
    prod = "prod-bucket"
  }

  bucket = each.value
}

count creates multiple identical resources using an index (count.index).

terraform import ⭐ (VERY important)
terraform taint / untaint

lifecycle {
  prevent_destroy = true
}

sensitive = true

terraform workspace new dev
terraform workspace new prod



data "azurerm_resource_group" "existing" {
  name = "rg-existing"
}

provisioner "local-exec" {
  command = "echo hello"
}

terraform validate
terraform fmt
terraform plan -out=tfplan
terraform show tfplan

CI/CD Integration

You’ve done manual runs.

Now learn:

GitHub Actions
Azure DevOps pipelines

terraform state rm <resource>
