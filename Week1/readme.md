### Lab Setup 

Pre-requists: 

WSL Enabled for Windows 

## Install CLI's 


### Install kind 
https://kind.sigs.k8s.io/docs/user/quick-start/#installing-from-release-binaries

### Install Terraform 

https://developer.hashicorp.com/terraform/install


### Install helm 

Reference: 
https://helm.sh/docs/intro/install

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4
chmod 700 get_helm.sh
./get_helm.sh


### Install docker 

https://docs.docker.com/desktop/setup/install/windows-install/


### Install kubectl 

https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

### Install K9S 

https://github.com/derailed/k9s

### Install Lens 

https://lenshq.io/download 



Terraform: 

terraform-kind.yaml

kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
  - role: worker
networking:
  podSubnet: "10.244.0.0/16"
  serviceSubnet: "10.96.0.0/12"

Create kind cluster 

kind delete cluster --name kind-my-kind-cluster
kind create cluster --name my-kind-cluster --config kind-config.yaml
kubectl config delete-context kind-my-kind-cluster
