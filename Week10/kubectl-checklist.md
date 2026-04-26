☸️ kubectl Quick Cheat Sheet
🚀 Cluster Info
kubectl cluster-info → Show cluster endpoints
kubectl version → Client & server version
kubectl config get-contexts → List contexts
kubectl config use-context <name> → Switch cluster

📦 Get Resources
kubectl get pods → List pods
kubectl get nodes → List nodes
kubectl get svc → List services
kubectl get all → All resources in namespace
kubectl get pods -A → All namespaces
kubectl get pod <name> -o wide → More details

🔍 Describe & Debug
kubectl describe pod <name> → Detailed pod info
kubectl logs <pod> → View logs
kubectl logs -f <pod> → Follow logs
kubectl logs <pod> -c <container> → Specific container
kubectl top pods → CPU/memory usage

🛠️ Create & Apply
kubectl apply -f file.yaml → Create/update resource
kubectl create -f file.yaml → Create resource
kubectl delete -f file.yaml → Delete resource

✏️ Edit Resources
kubectl edit deployment <name> → Edit live config
kubectl scale deployment <name> --replicas=3 → Scale app

🔄 Rollouts (Deployments)
kubectl rollout status deployment/<name> → Check rollout
kubectl rollout history deployment/<name> → History
kubectl rollout undo deployment/<name> → Rollback

🧪 Exec into Pods
kubectl exec -it <pod> -- /bin/bash → Shell into pod
kubectl exec <pod> -- ls → Run command

📁 Namespaces
kubectl get ns → List namespaces
kubectl create ns <name> → Create namespace
kubectl config set-context --current --namespace=<name> → Set default

🔐 Secrets & ConfigMaps
kubectl get secrets → List secrets
kubectl describe secret <name> → View details
kubectl get configmap → List configmaps

🌐 Services & Networking
kubectl get svc → List services
kubectl port-forward pod/<pod> 8080:80 → Access locally

🧹 Delete Resources
kubectl delete pod <name> → Delete pod
kubectl delete deployment <name> → Delete deployment

📊 Useful Flags
-n <namespace> → Specify namespace
-o yaml → Output YAML
-o json → Output JSON

⚡ Debugging Pods Quickly
kubectl get pods
kubectl describe pod <pod>
kubectl logs <pod>