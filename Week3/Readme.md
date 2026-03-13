
# Create kind cluster 

cat <<EOF | kind create cluster --name autoscale --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
EOF


# Install Metric Server: 

kubectl apply -f metricserver.yaml 

# Install Sample App with HPA 

kubectl apply -f hpa.yaml

# Test connectivity 

kubectl -n hpa-testing run -it --rm curltest --image=curlimages/curl:8.5.0 --restart=Never -- \
  sh -lc 'curl -v --max-time 5 http://hpa-test-app.hpa-testing.svc.cluster.local/health'

# Generate Load:

kubectl -n hpa-testing run -it --rm loadgen --restart=Never --image=curlimages/curl:8.5.0 -- \
  sh -lc 'while true; do curl -s http://hpa-test-app.hpa-testing.svc.cluster.local/ >/dev/null; done'


# More Load Generate 

NAME="loadgen-$(date +%s)-$RANDOM"

kubectl -n hpa-testing run "$NAME" --rm -it \
  --restart=Never \
  --image=busybox:1.36 \
  -- sh -lc 'while true; do wget -q -O- http://hpa-test-app.hpa-testing.svc.cluster.local/ >/dev/null; done'

# Alternative Load Genarator

cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  namespace: hpa-testing
  name: loadgen
spec:
  restartPolicy: Never
  containers:
  - name: loadgen
    image: busybox:1.36
    command: ["sh","-lc","while true; do wget -q -O- http://hpa-test-app.hpa-testing.svc.cluster.local/ >/dev/null; done"]
EOF


kubectl get pods -n hpa-testing 




# VPA Demo 

kubectl get crd | grep verticalpodautoscalers 


# Install VPA without helm 

kubectl apply -f https://raw.githubusercontent.com/kubernetes/autoscaler/master/vertical-pod-autoscaler/deploy/vpa-v1-crd-gen.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/autoscaler/master/vertical-pod-autoscaler/deploy/vpa-rbac.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/autoscaler/master/vertical-pod-autoscaler/deploy/recommender-deployment.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/autoscaler/master/vertical-pod-autoscaler/deploy/updater-deployment.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/autoscaler/master/vertical-pod-autoscaler/deploy/admission-controller-deployment.yaml

# Install VPA

 kubectl apply -f vpa.yaml

# Generate load 

cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  namespace: vpa-demo
  name: loadgen
spec:
  restartPolicy: Never
  containers:
  - name: loadgen
    image: busybox:1.36
    command: ["sh","-lc","while true; do wget -q -O- http://vpa-test-app.vpa-demo.svc.cluster.local/ >/dev/null; done"]
EOF


cat <<'EOF' > loadgen-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: loadgen
  namespace: vpa-demo
  labels:
    app: loadgen
spec:
  restartPolicy: Never
  containers:
  - name: loadgen
    image: busybox:1.36
    command:
    - sh
    - -lc
    - |
      while true; do
        wget -q -O- http://vpa-sample-app/ >/dev/null
      done
EOF



# Patch for Auto update of the pods

kubectl -n vpa-demo patch vpa vpa-sample-app --type merge -p \
  '{"spec":{"updatePolicy":{"updateMode":"Auto"}}}'

k top pods -n vpa-demo 

# Install Keda: 
helm repo add kedacore https://kedacore.github.io/charts
helm repo update
helm install keda kedacore/keda \
  --namespace keda \
  --create-namespace

  kubectl get crds | grep keda


# Deploy redis client and redis server 

kubectl apply -f keda.yaml

# Create a event: 

kubectl run redis-client -it --rm --image=redis -- bash
redis-cli -h redis

LPUSH jobs job1
LPUSH jobs job2
LPUSH jobs job3
LPUSH jobs job4
LPUSH jobs job5
LPUSH jobs job6

kubectl get pods 
kubectl get hpa 


# Create Kind Cluster:

cat <<EOF | kind create cluster --name ingress --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
EOF


docker network inspect ingress-control-plane


kubectl apply -f metalb.yaml



# Test LB: 

kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --type LoadBalancer --port 80


# Install gateway crd:

kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.1.0/standard-install.yaml
kubectl get crd | grep gateway


# Install kong helm 

helm repo add kong https://charts.konghq.com
helm repo update

helm install kong kong/kong \
  --namespace kong \
  --create-namespace \
  --set ingressController.enabled=true \
  --set ingressController.installCRDs=false \
  --set gateway.enabled=true \
  --set proxy.type=LoadBalancer

  helm upgrade kong kong/kong \
  -n kong \
  --reuse-values \
  --set ingressController.env.feature_gates="GatewayAlpha=true" \
  --set proxy.type=LoadBalancer

kubectl apply -f gatewayclass.yaml 

kubectl apply -f sample_deploy_ingress.yaml

# Install cilium using helm chart:

helm repo add cilium https://helm.cilium.io/
helm repo update

# Install Gateway CRD:

kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.1.0/standard-install.yaml
kubectl get crds | grep gateway

# Install cilium with gateway api enabled 

helm install cilium cilium/cilium \
  --namespace kube-system \
  --set gatewayAPI.enabled=true

# For the exsiting cluster with cilium installed 

 helm upgrade cilium cilium/cilium \
  --namespace kube-system \
  --reuse-values \
  --set gatewayAPI.enabled=true

kubectl get pods -n kube-system -l k8s-app=cilium
kubectl -n kube-system exec ds/cilium -- cilium status


kubectl apply -f ingress.yaml 

docker exec -it gateway-api-control-plane  /bin/sh
echo "172.18.0.9 app.local" >> /etc/hosts



# Scaling 
- Install Metric Server:
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl get deployment metrics-server -n kube-system


