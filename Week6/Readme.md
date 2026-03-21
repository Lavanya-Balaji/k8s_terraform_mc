# Create namespace
kubectl create namespace argocd

# Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Expose ArgoCD server (for testing)
kubectl port-forward svc/argocd-server -n argocd 8080:443

kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo

## Create Git Repo 

Argo UI -> Settings -> Repositories ->  Connect Repo -> type: git , Repo: https://github.com/Lavanya-Balaji/k8s_terraform_mc, User Name and Password PAT Token -> Success 



https://github.com/Lavanya-Balaji/k8s_terraform_mc

## HELM Repo:
Repo: https://charts.bitnami.com/bitnami

chart: nginx-ingress-controller



### OCI Repo: 



