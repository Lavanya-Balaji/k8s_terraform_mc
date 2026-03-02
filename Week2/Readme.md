## Create kind Cluster
* Multiple controlplane kind Cluster
* Disable the default CNI - Kindnest and use Calico 

## Check Node Status

kubectl get nodes

## Install Custom CNI 

helm repo add cilium https://helm.cilium.io/
helm repo update
helm install cilium cilium/cilium \
  --namespace kube-system \
  --set ipam.mode=kubernetes


## check the Node status 

## check the IP Table rules
kind create cluster --name iptables-lab --image kindest/node:v1.29.2
docker exec -it iptables-lab-control-plane bash


kubectl create deployment nginx-deployment --image=nginx
kubectl scale deployment nginx-deployment --replicas=5

iptables -t nat -L | grep KUBE-SEP


## create a cluster called cilium 

cat <<EOF | kind create cluster --name cilium-lab --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  disableDefaultCNI: true
  kubeProxyMode: "none"
nodes:
- role: control-plane
EOF


## Install cilium in the kind cluster: 

❯ cilium install \
  --version 1.15.5 \
  --set kubeProxyReplacement=strict

## Validate kube-proxy replaced by Cilium CNI 
❯ kubectl get pods -n kube-system
NAME                                               READY   STATUS    RESTARTS   AGE
cilium-operator-579ddb5cd7-drlr8                   1/1     Running   0          90s
cilium-qbptl                                       1/1     Running   0          90s
coredns-7db6d8ff4d-t24hx                           1/1     Running   0          90s
coredns-7db6d8ff4d-z2xzt                           1/1     Running   0          90s
etcd-cilium-lab-control-plane                      1/1     Running   0          105s
kube-apiserver-cilium-lab-control-plane            1/1     Running   0          106s
kube-controller-manager-cilium-lab-control-plane   1/1     Running   0          105s
kube-scheduler-cilium-lab-control-plane            1/1     Running   0          105s


## Cilium status 
cilium hubble enable
cilium status
cilium connectivity test

## Cilium is enabled or not ? 
docker exec it cilium-lab-controlplane bash 
ip route
