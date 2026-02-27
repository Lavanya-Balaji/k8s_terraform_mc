# Lab Setup

## Prerequisites

- WSL Enabled for Windows

## Install CLIs 


### Install kind

Reference: https://kind.sigs.k8s.io/docs/user/quick-start/#installing-from-release-binaries

### Install Terraform

Reference: https://developer.hashicorp.com/terraform/install

### Install Helm

Reference: https://helm.sh/docs/intro/install

```bash
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4
chmod 700 get_helm.sh
./get_helm.sh
```

### Install Docker

Reference: https://docs.docker.com/desktop/setup/install/windows-install/

### Install kubectl

Reference: https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/

```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
```

### Install K9s

Reference: https://github.com/derailed/k9s

### Install Lens

Reference: https://lenshq.io/download 

## Create Kind Cluster

Create a `kind-config.yaml` file with the following configuration:

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
  - role: worker
networking:
  podSubnet: "10.244.0.0/16"
  serviceSubnet: "10.96.0.0/12"
```

Create the cluster:

```bash
kind create cluster --name my-kind-cluster --config kind-config.yaml
```

## Docker Image 
docker run -d --name my-nginx-test  -p 8081:80 nginx:latest
docker rm -f my-nginx-test
docker ps
docker stop f969d47d5f7f
<!-- 
- Load Test:

docker run -d \
  --name stressed-nginx \
  -p 8082:80 \
  --cpus="0.2" \
  --memory="10m" \
  nginx:latest

docker stats stressed-nginx

for i in {1..10000}; do curl -s http://localhost:8082 > /dev/null & done -->


## Create Deployment 

```bash
kubectl get pods -n kube-system
kubectl get pods --all-namespaces

kubectl create deployment nginx-deployment --image=nginx
kubectl scale deployment nginx-deployment --replicas 2
kubectl logs <pod_name> -n kube-system
kubectl expose deployment nginx-deployment --port 8080
kubectl port-forward svc/nginx-deployment 8080:8080

```
## Exec into controlplane node 
```bash
docker exec -it my-kind-cluster-control-plane bash 
```
## Observe Control plane pods behaviour


ls /etc/kubernetes/manifests

etcd.yaml  kube-apiserver.yaml	kube-controller-manager.yaml  kube-scheduler.yaml

mv /etc/kubernetes/manifests/<.yaml> /tmp/

## Delete Kind Cluster

```bash
kind delete cluster --name my-kind-cluster
```

## Delete the Context

```bash
kubectl config delete-context kind-my-kind-cluster
```
