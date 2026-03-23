# Create Kind Cluster

cat <<EOF | kind create cluster --name argo --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
EOF

# Create namespace
kubectl create namespace argocd

# Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml


# Enable SSO 

https://console.cloud.google.com/projectselector2/apis/credentials?pli=1&supportedpurview=project -> Create a Project -> Create Credentails -> Oauth Client ID -> Create Consent 

Create Oauth Client ID -> Web application -> Java Script Origin: http://localhost:8080 ->  Authorized Redirect URL. http://localhost:8080/api/dex/callback


kubectl edit configmap argocd-cm -n argocd 

data:
  url: http://localhost:8080

  dex.config: |
    connectors:
    - type: oidc
      id: google
      name: Google
      config:
        issuer: https://accounts.google.com
        clientID: <YOUR_CLIENT_ID>
        clientSecret: <YOUR_CLIENT_SECRET>
        redirectURI: http://localhost:8080/api/dex/callback
        scopes:
        - openid
        - profile
        - email
  kubectl rollout restart deployment argocd-server -n argocd
kubectl rollout restart deployment argocd-dex-server -n argocd

# Allow Insecure argo url to allow http login 

❯ kubectl patch deployment argocd-server -n argocd \
  -p '{"spec":{"template":{"spec":{"containers":[{"name":"argocd-server","args":["argocd-server","--insecure"]}]}}}}'
deployment.apps/argocd-server patched
❯ kubectl port-forward svc/argocd-server -n argocd 8080:443

#  kubectl edit configmap argocd-cm -n argocd
   policy.csv: |
    g, your-email@gmail.com, role:admin 

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



