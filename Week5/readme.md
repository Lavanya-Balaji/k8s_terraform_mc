

## Create Kind Cluster 

```
cat <<EOF | kind create cluster --name istio --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
EOF
```

## Create a LoadBalancer Service 
```
kubectl create deployment my-app --image=nginx
kubectl expose deployment my-app \
  --type=LoadBalancer \
  --port=80 \
  --target-port=80 \
  --name=my-service 
```

## Enable MetaLB
```
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.12/config/manifests/metallb-native.yaml
docker network inspect kind | grep -i subnet
kubectl apply -f metalb.yaml
```


## Test Load Balancer Service 
```
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --type=LoadBalancer --port=80
kubectl run -it --rm curlpod --image=curlimages/curl:8.5.0 --restart=Never -- sh
curl http://172.18.255.200 -> External IP of the Nginx Service 

```
## Ingress Nginx Controller
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
kubectl get pods -n ingress-nginx
kubectl get svc 
```
## Create Ingress and Deployment
```
kubectl apply -f ingress.yaml 

curl http://172.18.255.201/
curl http://172.18.255.200/api
```
## Install Istioctl CLI 
```
curl -L https://istio.io/downloadIstio | sh -
```

## Istio Installation: 
```
istioctl install --set profile=demo -y
kubectl get pods -n istio-system
kubectl get svc -n istio-system
```
## Enable istio for namespaces
kubectl create namespace my-namespace
kubectl label namespace my-namespace istio-injection=enabled

kubectl apply -f istio.yaml
kgp -n my-namespace -oyaml 

## How to access the service in kind cluster
kubectl port-forward svc/istio-ingressgateway -n istio-system 8082:80
http://127.0.0.1:8082


## Simple Istio Deployment with two versions
kubectl apply -f routing-istio-for-deployment.yaml

http://127.0.0.1:8082/api
http://127.0.0.1:8082/web

kubectl delete -f routing-istio-for-deployment.yaml

## Blue Greeen Deployment with Istio 

kubectl apply -f istio-blue-green-deployment.yaml
kubectl port-forward svc/istio-ingressgateway -n istio-system 8082:80

http://127.0.0.1:8082/api
http://127.0.0.1:8082/
kubectl delete -f istio-blue-green-deployment.yaml

## Canary Rollout with istio 

kubectl apply -f istio-canary-dpeloyment.yaml
docker exec -it istio-control-plane  /bin/sh

for i in $(seq 1 200); do curl -s http://172.18.255.202/api; echo; done | sort | uniq -c


kubectl delete -f istio-canary-dpeloyment.yaml


## Test Time Outs and retry

kubectl apply -f istio-timeout.yaml
kubectl port-forward svc/istio-ingressgateway -n istio-system 8082:80
curl -v http://127.0.0.1:8082/api # Expected Result is "upstream request timeout" - app takes 5 seconds and istio allows only 2 seconds 

docker exec -it istio-control-plane  /bin/sh


apt update && apt install -y curl 



## kiali Intallation: 
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.22/samples/addons/kiali.yaml

kubectl -n istio-system port-forward svc/kiali 20001:20001
http://127.0.0.1:20001/

## Install prometheus and Grafana 
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.22/samples/addons/prometheus.yaml
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.22/samples/addons/grafana.yaml
kubectl -n istio-system port-forward svc/prometheus 9090:9090
kubectl -n istio-system port-forward svc/grafana 3000:3000


## Install Sample App:


kubectl label namespace default  istio-injection=enabled --overwrite
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.22/samples/bookinfo/platform/kube/bookinfo.yaml
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.22/samples/bookinfo/networking/bookinfo-gateway.yaml


