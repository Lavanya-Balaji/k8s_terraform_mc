

## Install Custom CNI 

helm repo add cilium https://helm.cilium.io/
helm repo update
helm install cilium cilium/cilium \
  --namespace kube-system \
  --set ipam.mode=kubernetes


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


## Demo for IP Tables rules update
1. Create kind Cluster: 
   
- kind create cluster --name iptables-demo --config kind.yaml

2. Create a Nginx Deployment and Expose it: 
   
- kubectl create deployment nginx-deployment --image=nginx --replicas=5
- kubectl expose deployment nginx-deployment --port 80
- kubectl port-forward svc/nginx-deployment 8080:80

3. Connect to the Controlplane 
  
  docker exec -it iptables-demo-control-plane bash

  connect to ingress services: 
    for i in {1..100}; do 
    curl 10.96.213.76 :8080
     sleep 1 
     done 

1. Check all the IP Tables Rules:
-  iptables -t nat -L 
-  iptables -t nat -L KUBE-SERVICES // check for the nginx service 

Now delete the nginx pods, automatically these rules are updated for the nginx services

-  iptables -t nat -L KUBE-SVC-WRNOD73BKRQH4VVX

# Mode of IP tables:  iptables / ipvs / userspace 

kubectl get configmap kube-proxy -n kube-system -o yaml | grep mode
    mode: iptables


## Demo cilium 
1. Create a Minikube cluster 
   minikube start --driver=docker --memory=4096 --cpus=4   
2. Install Cilium CLI 
    https://docs.cilium.io/en/stable/gettingstarted/k8s-install-default/#install-the-cilium-cli
 cilium install 
 cilium status 
 cilium hubble enable --ui 
 kubectl -n kube-system port-forward svc/hubble-ui 12000:80
3. Deploy FrontEnd:
 kubectl create ns demo 
 kubectl create deployment nginx-backend -n demo  --image=nginx --replicas 4
kubectl expose deployment nginx-backend -n demo --port 80
4. Deploy Backend: 
kubectl create deployment nginx-frontend -n demo  --image=nginx --replicas 4
kubectl expose deployment nginx-backend -n demo --port 80

5. Create Label 
kubectl label deployments.apps -n demo nginx-frontend app=frontend --overwrite

kubectl label deployments.apps -n demo nginx-backend app=backend --overwrite

6. Test connectivity: 
   kubectl -n demo exec -it deployments/nginx-frontend -- sh 
   curl http://nginx-backend -> you will nginx Access the backend service 

7. Check Hubble 
   Traffic Forwarded / Traffic Dropped    


   Allow or Block Traffic 

8. Check the curl connectivity again 
9.    kubectl -n demo exec -it deployments/nginx-frontend -- sh 
   curl http://nginx-backend -> you will nginx Access the backend service  you will see timeout 



### ETCD Backup and Restore: 

- create kind Cluster: 

kind create cluster --name etcd

- Create Sample Applications: 

kubectl create ns test
kubectl create ns test2
kubectl create ns test3
kubectl create deployment nginx --image=nginx --replicas 4

- Install ETCDCTL: 
  
docker exec -it etcd-control-plane bash
apt update
apt install etcd-client -y
etcdctl version

- Take Snapshot: 
  
ETCDCTL_API=3 etcdctl snapshot save snapshot.db   --endpoints=https://127.0.0.1:2379   --cacert=/etc/kubernetes/pki/etcd/ca.crt   --cert=/etc/kubernetes/pki/etcd/server.crt   --key=/etc/kubernetes/pki/etcd/server.key

- Take a Copy of snapshot.db to host machine
  
  docker cp etcd-control-plane:/snapshot.db ./snapshot.db

- Restore on to the same cluster 
  kubectl create ns test4 
  kubectl create ns test5 
  kubectl create ns test6

systemctl stop kubelet
pkill kubelet
ls /var/lib/etcd
ETCDCTL_API=3 etcdctl snapshot restore /snapshot.db \
  --data-dir=/var/lib/etcd
systemctl start kubelet

Exit the docker and restart the docker container
docker restart etcd-control-plane

- Restore on to the new cluster
  
  kind create cluster --name etcd-new-cluster-restore
  docker stop etcd-new-cluster-restore-control-plane
  docker cp snapshot.db etcd-new-cluster-restore-control-plane:/snapshot.db
  docker start etcd-new-cluster-restore-control-plane
  pkill kubelet
  rm -rf /var/lib/etcd
  apt update
  apt install etcd-client -y
  etcdctl version
  rm -rf /var/lib/etcd
  ETCDCTL_API=3 etcdctl snapshot restore /snapshot.db \
    --data-dir=/var/lib/etcd
  docker restart etcd-new-cluster-restore-control-plane
  kubectl get ns
  kubectl get pods -A


