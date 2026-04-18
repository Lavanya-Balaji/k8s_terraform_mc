## kind cluster creation
```
cat <<EOF | kind create cluster --name monitoring --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
EOF
```
## Install Metrics Monitoring Tool 
## Add repos
```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```
## Deploy Prometheus
```
helm install prometheus prometheus-community/prometheus --namespace monitoring --create-namespace
  export POD_NAME=$(kubectl get pods --namespace monitoring -l "app.kubernetes.io/name=prometheus,app.kubernetes.io/instance=prometheus" -o jsonpath="{.items[0].metadata.name}")
  kubectl --namespace monitoring port-forward $POD_NAME 9090

```


## Install Full Stack: 

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace
  

## Install and configure tracing tool 

kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml   
kubectl apply -f https://github.com/open-telemetry/opentelemetry-operator/releases/latest/download/opentelemetry-operator.yaml
kubectl get pods -n opentelemetry-operator-system

cat <<EOF | kubectl apply -f -
apiVersion: opentelemetry.io/v1beta1
kind: OpenTelemetryCollector
metadata:
  name: otel-collector
spec:
  mode: deployment
  config:
    receivers:
      otlp:
        protocols:
          grpc: {}
          http: {}

    processors:
      batch: {}

    exporters:
      debug: {}

    service:
      pipelines:
        traces:
          receivers: ["otlp"]
          processors: ["batch"]
          exporters: ["debug"]
EOF

helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm install tempo grafana/tempo
helm install grafana grafana/grafana
kubectl get secret grafana -o jsonpath="{.data.admin-password}" | base64 --decode
export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=grafana" -o jsonpath="{.items[0].metadata.name}")

kubectl --namespace default port-forward $POD_NAME 3000

cat <<EOF | kubectl apply -f -
apiVersion: opentelemetry.io/v1beta1
kind: OpenTelemetryCollector
metadata:
  name: otel-collector
spec:
  mode: deployment
  config:
    receivers:
      otlp:
        protocols:
          grpc: {}
          http: {}

    processors:
      batch: {}

    exporters:
      otlp:
        endpoint: tempo:4317
        tls:
          insecure: true

    service:
      pipelines:
        traces:
          receivers: ["otlp"]
          processors: ["batch"]
          exporters: ["otlp"]
EOF

cat <<EOF | kubectl apply -f -
apiVersion: opentelemetry.io/v1beta1
kind: OpenTelemetryCollector
metadata:
  name: otel-collector
spec:
  mode: deployment
  config:
    receivers:
      otlp:
        protocols:
          grpc: {}
          http: {}

    processors:
      batch: {}

    exporters:
      otlp:
        endpoint: tempo:4317
        tls:
          insecure: true

    service:
      pipelines:
        traces:
          receivers: ["otlp"]
          processors: ["batch"]
          exporters: ["otlp"]
EOF

kubectl rollout restart deployment otel-collector-collector
Add Tempo in Grafana

In Grafana UI:

Go → Connections → Data Sources
Add Data Source → Select Tempo
URL:
http://tempo:3200
Test 

## Deploy Grafana
```
helm install grafana grafana/grafana --namespace monitoring

kgp -n monitoring

   kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo




     export POD_NAME=$(kubectl get pods --namespace monitoring -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=grafana" -o jsonpath="{.items[0].metadata.name}")
     kubectl --namespace monitoring port-forward $POD_NAME 3000

kubectl port-forward -n monitoring service/prometheus-server 9090:80
```


## Sample Query:

node_cpu_seconds_total
node_memory_MemAvailable_bytes
kube_pod_info
sum by (node)(rate(node_cpu_seconds_total[5m])) 


Grafana Dashboard:
DataSource for Kind Cluster: 
http://prometheus-server.monitoring.svc.cluster.local:80

Dashboard ID: 315 

Node CPU Usage% :
100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
sum(rate(container_cpu_usage_seconds_total[5m])) by (pod)

Pod CPU Usage
sum(rate(container_cpu_usage_seconds_total[5m])) by (pod)

Pod Memory Usage
sum(container_memory_usage_bytes) by (pod)

Node Memory Usage %
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100

HTTP / Application Metrics
Request Rate (RPS)
sum(rate(http_requests_total[5m]))

Requests per Service
sum(rate(http_requests_total[5m])) by (service)

Error Rate (%)
sum(rate(http_requests_total{status=~"5.."}[5m])) 
/ 
sum(rate(http_requests_total[5m])) * 100

Latency (95th percentile)
histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket[5m])) by (le))

👉 Used everywhere in production systems

Pod Restart Count
increase(kube_pod_container_status_restarts_total[10m])
Running Pods per Namespace
count(kube_pod_status_phase{phase="Running"}) by (namespace)

Pod Status (Non-running)
kube_pod_status_phase{phase!="Running"}

Disk & Network
Disk Usage %
(node_filesystem_size_bytes - node_filesystem_free_bytes) 
/ node_filesystem_size_bytes * 100

High CPU Alert
100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80

High Memory Alert
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100 > 85
