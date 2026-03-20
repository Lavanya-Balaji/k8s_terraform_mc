

## Create Kind Cluster 

cat <<EOF | kind create cluster --name istio --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
EOF


## Enable MetaLB
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.12/config/manifests/metallb-native.yaml
docker network inspect kind | grep -i subnet
kubectl apply -f metalb.yaml



## Test Load Balancer Service 
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --type=LoadBalancer --port=80
kubectl run -it --rm curlpod --image=curlimages/curl:8.5.0 --restart=Never -- sh
curl http://172.18.255.200 -> External IP of the Nginx Service 

## Ingress Nginx Controller

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
kubectl get pods -n ingress-nginx
kubectl get svc 

## Create Ingress and Deployment

kubectl apply -f ingress.yaml 

curl http://172.18.255.201/
curl http://172.18.255.200/api

## Install Istioctl CLI 
curl -L https://istio.io/downloadIstio | sh -

## Istio Installation: 
istioctl install --set profile=demo -y
kubectl get pods -n istio-system
kubectl get svc -n istio-system

# Enable istio for namespaces
kubectl create namespace my-namespace
kubectl label namespace my-namespace istio-injection=enabled

kubectl apply -f istio.yaml
kgp -n my-namespace -oyaml 

kubectl port-forward svc/istio-ingressgateway -n istio-system 8082:80
http://127.0.0.1:8082/api
http://127.0.0.1:8082/


