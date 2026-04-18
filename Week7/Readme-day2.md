## Install Prometheus and Grafana for Metrics: 
```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace

kubectl get secret -n monitoring monitoring-grafana \
  -o jsonpath="{.data.admin-password}" | base64 --decode

kubectl port-forward -n monitoring svc/monitoring-grafana 3000:80


Query:

avg(container_memory_usage_bytes{pod=~”.*”}) by (pod) / (1024 * 1024)

```

## Install loki for logs: 



##  Install Loki for logs: 
```
  helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

helm install loki grafana/loki --set loki.useTestSchema=true \
  -n monitoring --create-namespace \
  --set deploymentMode=SingleBinary \
  --set loki.auth_enabled=false \
  --set loki.commonConfig.replication_factor=1 \
  --set loki.storage.type=filesystem \
  --set singleBinary.replicas=1 \
  --set read.replicas=0 \
  --set write.replicas=0 \
  --set backend.replicas=0 \
  --set chunksCache.enabled=false \
  --set resultsCache.enabled=false \
  --set gateway.enabled=false



helm install promtail grafana/promtail \
  -n monitoring \
  --set "config.clients[0].url=http://loki.monitoring.svc.cluster.local:3100/loki/api/v1/push"

 
 kubectl run test --image=nginx

Go to Settings → Data Sources -> Click Add data source -> Select Loki

Add a Loki Data Source: http://loki.monitoring.svc.cluster.local:3100

  ```

## Install  tracing : 

helm install tempo grafana/tempo \
  -n monitoring \
  --set tempo.storage.trace.backend=local \
  --set tempo.storage.trace.local.path=/var/tempo/traces \
  --set tempo.retention=1h \
  --set tempo.resources.requests.memory=256Mi \
  --set tempo.resources.limits.memory=512Mi

helm install tempo grafana/tempo \
  -n monitoring \
  --set tempo.storage.trace.backend=local \
  --set tempo.storage.trace.local.path=/var/tempo/traces \
  --set tempo.reportingEnabled=false \
  --set singleBinary.enabled=true

  http://tempo.monitoring.svc.cluster.local:3200




## Install otel collector 

helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
helm repo update

helm install otel-collector open-telemetry/opentelemetry-collector \
  -n monitoring \
  --set mode=deployment \
  --set image.repository=otel/opentelemetry-collector-contrib \
  --set image.tag=latest \
  --set resources.requests.memory=256Mi \
  --set resources.limits.memory=512Mi \
  --set config.receivers.otlp.protocols.grpc.endpoint="0.0.0.0:4317" \
  --set config.receivers.otlp.protocols.http.endpoint="0.0.0.0:4318" \
  --set config.exporters.otlp.endpoint="tempo.monitoring.svc.cluster.local:4317" \
  --set config.exporters.otlp.tls.insecure=true \
  --set config.service.pipelines.traces.receivers="{otlp}" \
  --set config.service.pipelines.traces.exporters="{otlp}"



# Install a otel demo app: 

kubectl apply -f https://github.com/open-telemetry/opentelemetry-operator/releases/latest/download/instrumentation.yaml 


helm install otel-demo open-telemetry/opentelemetry-demo \
  -n otel-demo --create-namespace
