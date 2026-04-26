### 🚀 Setup & Init
terraform init → Initialize project (download providers/modules)
terraform init -upgrade → Upgrade providers/modules
terraform init -reconfigure → Reinitialize backend config
terraform init -migrate-state → Move state to new backend

### 📋 Plan & Apply

terraform plan → Preview changes
terraform plan -out=tfplan → Save plan to file
terraform apply → Apply changes
terraform apply tfplan → Apply saved plan

### 🎯 Targeted Actions (use carefully)
terraform plan -target=<resource> → Plan specific resource
terraform apply -target=<resource> → Apply specific resource

### 🔄 Resource Replacement
terraform apply -replace="<resource>" → Force recreate resource

### 📦 State Management
terraform state list → List resources in state
terraform state show <resource> → Show resource details
terraform state rm <resource> → Remove from state (not deleted in cloud)
terraform import <resource> <id> → Import existing resource

### 🧹 Formatting & Validation
terraform fmt → Format code
terraform validate → Validate configuration

### 🏗️ Destroy
terraform destroy → Delete all resources
terraform destroy -target=<resource> → Delete specific resource



terraform-repo/
│
├── modules/                # Reusable building blocks
│   ├── storage/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │
│   ├── aks/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │
│   └── network/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│
├── environments/           # Environment-specific configs
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── terraform.tfvars
│   │   └── backend.tf
│   │
│   ├── staging/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── terraform.tfvars
│   │   └── backend.tf
│   │
│   └── prod/
│       ├── main.tf
│       ├── variables.tf
│       ├── terraform.tfvars
│       └── backend.tf
│
└── README.md