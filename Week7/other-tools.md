# Node Labels:
kubectl label nodes monitoring-cluster-worker workload=regular

kubectl apply -f node-selector.yaml 
kubectl run nginx --image=nginx --restart=Never

kubectl apply -f affinity.yaml

kubectl taint nodes monitoring-cluster-worker2 dedicated=database:NoSchedule


# Velero installation 
# Use Minio for storage 
helm install minio minio/minio \
  -n velero \
  --set mode=standalone \
  --set replicas=1 \
  --set rootUser=admin \
  --set rootPassword=admin123 \
  --set persistence.enabled=false \
  --set resources.requests.memory=256Mi \
  --set resources.requests.cpu=100m


cat <<EOF > credentials-velero
[default]
aws_access_key_id = admin
aws_secret_access_key = admin123
EOF


helm repo add vmware-tanzu https://vmware-tanzu.github.io/helm-charts
helm repo update

helm install velero vmware-tanzu/velero \
  -n velero \
  --set-file credentials.secretContents.cloud=credentials-velero \
  --set 'configuration.backupStorageLocation[0].name=default' \
  --set 'configuration.backupStorageLocation[0].provider=aws' \
  --set 'configuration.backupStorageLocation[0].bucket=velero' \
  --set 'configuration.backupStorageLocation[0].config.region=minio' \
  --set 'configuration.volumeSnapshotLocation[0].name=default' \
  --set 'configuration.volumeSnapshotLocation[0].provider=aws' \
  --set 'configuration.volumeSnapshotLocation[0].config.region=minio'

kubectl create ns demo-app



cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: demo-pvc
  namespace: demo-app
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: demo-nginx
  namespace: demo-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: demo-nginx
  template:
    metadata:
      labels:
        app: demo-nginx
    spec:
      containers:
        - name: nginx
          image: nginx:stable
          volumeMounts:
            - mountPath: /usr/share/nginx/html
              name: storage
      volumes:
        - name: storage
          persistentVolumeClaim:
            claimName: demo-pvc
EOF

kubectl exec -n demo-app deploy/demo-nginx -- sh -c \
  "echo 'HELLO FROM VELERO BACKUP' > /usr/share/nginx/html/index.html"


  curl -L https://github.com/vmware-tanzu/velero/releases/latest/download/velero-linux-amd64.tar.gz -o velero.tar.gz
tar -xvf velero.tar.gz
sudo mv velero*/velero /usr/local/bin/


velero backup create demo-backup \
  --include-namespaces demo-app

helm repo add aqua https://aquasecurity.github.io/helm-charts/
helm repo update

helm upgrade --install trivy-operator aqua/trivy-operator --create-namespace \
  -n trivy-system \
  --set 'operator.nodeCollector.tolerations[0].operator=Exists' \
  --set 'operator.nodeCollector.tolerations[0].effect=NoSchedule' \ 
  --set operator.nodeCollector.enabled=false

helm repo add minio https://charts.min.io/
helm install minio minio/minio \
  -n velero --create-namespace \
  --set rootUser=admin \
  --set rootPassword=admin123

helm repo add vmware-tanzu https://vmware-tanzu.github.io/helm-charts/
helm repo update

