# Install Metrics Monitoring Tool 
## Add repos
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

## Deploy Prometheus
helm install prometheus prometheus-community/prometheus --namespace monitoring --create-namespace

## Deploy Grafana
helm install grafana grafana/grafana --namespace monitoring

kgp -n monitoring

   kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo



     export POD_NAME=$(kubectl get pods --namespace monitoring -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=grafana" -o jsonpath="{.items[0].metadata.name}")
     kubectl --namespace monitoring port-forward $POD_NAME 3000

kubectl port-forward -n monitoring service/prometheus-server 9090:80


Sample Query:
node_cpu_seconds_total
node_memory_MemAvailable_bytes
kube_pod_info
sum by (node)(rate(node_cpu_seconds_total[5m])) 


Grafana Dashboard:
DataSource for Kind Cluster: 
http://prometheus-server.monitoring.svc.cluster.local:80

Dashboard ID: 315 
