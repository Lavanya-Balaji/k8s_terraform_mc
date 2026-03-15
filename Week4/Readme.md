### Lab for Storage 

Node Disk
   ↓
PersistentVolume
   ↓
PersistentVolumeClaim
   ↓
Deployment
   ↓
Pod mounts storage


## Create a deployment with No Storage option

kubectl apply -f no_stg_provisioning.yaml
kubectl exec -it deployments/nginx-no-storage-deployment -- bash
echo "this will disappear" > /usr/share/nginx/html/test.txt
kubectl rollout restart deployments/nginx-no-storage-deployment 
or 
kubectl delete pod <pod-name>

kubectl exec -it deployments/nginx-no-storage-deployment -- ls /usr/share/nginx/html


## Create Persistent storage 

kubectl apply -f static_provisioning.yaml
kubectl exec -it deployments/nginx-storage-deployment -- cat /data/app.log
kubectl rollout restart deployments/nginx-no-storage-deployment 


## Create Dymanic Persistent storage 

kubectl get storageclass
kubectl apply -f dynamic_provisioning.yaml
kg pvc  dynamic-pvc -oyaml
kubectl exec -it deployments/nginx-dynamic-storage-deployment -- bash
echo "Dynamic Storage Works" > /usr/share/nginx/html/data/test.txt
cat /usr/share/nginx/html/data/test.txt
kubectl rollout restart deployments/nginx-dynamic-storage-deployment
kubectl exec -it deployments/nginx-dynamic-storage-deployment -- cat /usr/share/nginx/html/data/test.txt


## RBAC: 

kubectl create namespace dev

kubectl apply -f role_rolebinding.yaml
kubectl get role -n dev
kubectl get rolebinding -n dev
kubectl auth can-i list pods --as=dev-user -n dev // Dev user can list pods ? 
kubectl auth can-i get pods --as=dev-user -n dev
kubectl auth can-i create pods --as=dev-user -n dev
kubectl auth can-i delete pods --as=dev-user -n dev
kubectl auth can-i list pods --as=dev-user -n default
kubectl run nginx --image=nginx -n dev
kubectl auth can-i get pods --as=dev-user -n dev
kubectl auth can-i delete pod nginx --as=dev-user -n dev

kubectl apply -f clusterrole_clusterrolebinding.yaml

kubectl get clusterrole
kubectl get clusterrolebinding

kubectl auth can-i list pods --as=cluster-user -n default
kubectl auth can-i list pods --as=cluster-user -n kube-system
kubectl auth can-i create pods --as=cluster-user
kubectl auth can-i delete pods --as=cluster-user

kubectl run nginx --image=nginx
kubectl run nginx2 --image=nginx -n kube-system
kubectl auth can-i get pods --as=cluster-user -n default
kubectl auth can-i get pods --as=cluster-user -n kube-system

# Helm charts 
 kubectl apply -f Without_helm_chart.yaml
 helm create demo-app

 kubectl delete -f Without_helm_chart.yaml
 
 helm install demo-release ./demo-app

 kubectl label namespace demo app.kubernetes.io/managed-by=Helm

 kubectl annotate namespace demo meta.helm.sh/release-name=demo-release


 helm install cilium cilium/cilium \
  --namespace kube-system \
  --set kubeProxyReplacement=true \
  --set gatewayAPI.enabled=true
  