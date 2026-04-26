### 🚀 Kubernetes Cluster Upgrade Plan
    📅 Upgrade Strategy
        Plan cluster upgrades every 3 months
        Ensure the cluster is always running a supported Kubernetes version
        Notify all stakeholders in advance about the upgrade schedule
### 🔍 Pre-Upgrade Checks
1. Compatibility & Readiness
    Review Kubernetes release notes
    Verify version compatibility with all tools
    Check compatibility matrix for:
        ArgoCD https://argo-cd.readthedocs.io/en/stable/operator-manual/tested-kubernetes-versions/ 
        Istio https://istio.io/latest/docs/releases/supported-releases/ 
        Cilium https://docs.cilium.io/en/latest/network/kubernetes/compatibility/ 
        Kyverno https://kyverno.io/docs/installation/installation/#compatibility-matrix 
        Velero https://github.com/velero-io/velero 
    Upgrade any incompatible tools beforehand

2. API & Configuration Validation
Scan for deprecated APIs using:
kubent or pluto
Validate Pod Disruption Budgets (PDBs) for misconfigurations

3. Backup & Health Checks
Backup cluster state using Velero
Ensure all workloads are healthy:
No failing or pending pods
Capture a snapshot/screenshot for reference

4. Capacity Planning
Verify node pool capacity and max surge settings
Ensure the cluster subnet has enough IP space to handle additional nodes during upgrade

### 🧪 Non-Production Upgrade
```json
    Perform upgrade in non-prod environment first
    Choose upgrade approach:
    Control plane + worker nodes together
    OR upgrade control plane and worker nodes separately
    Freeze all deployments during the upgrade window (no releases)
```
### 📊 During Upgrade
Monitor:
    Node status
    Pod health
    Alerts and logs
### ✅ Post-Upgrade Validation
    Validate all applications
    Check monitoring dashboards
    Perform functional testing of:
    Infrastructure tools
    Platform components
    Inform application teams to verify their services
### ⏳ Stabilization Period
    Monitor the environment for 1–2 weeks
    Ensure stability before proceeding to production
### 🏭 Production Upgrade
    Communicate upgrade plan to all stakeholders
    Repeat the same steps followed in non-production:
    Pre-checks
    Backup
    Upgrade
    Validation
    Closely monitor post-upgrade
### 📌 Key Practices
    No deployments during upgrade window
    Always validate compatibility before upgrading
    Ensure proper monitoring and rollback readiness