🌐➡️☸️ App Down Troubleshooting (External → Pod)
🔍 1. Check from External World
🌐 DNS Resolution
nslookup your-domain.com
❌ Fails → DNS issue
✅ Works → move next
🌍 Endpoint Reachability
curl -v https://your-domain.com

Check:

timeout → network/firewall
404/502/503 → ingress/app issue
🌐 2. Load Balancer / Ingress
Check Ingress
kubectl get ingress
kubectl describe ingress <name>

Look for:

wrong backend service
missing rules
TLS issues
Check Ingress Controller (e.g., NGINX Ingress Controller)
kubectl get pods -n ingress-nginx
kubectl logs <ingress-pod> -n ingress-nginx
Check LoadBalancer Service
kubectl get svc
EXTERNAL-IP assigned?
Ports correct?
🔗 3. Service Layer
kubectl get svc
kubectl describe svc <service-name>

Check:

selector matches pod labels
correct port/targetPort
Test service internally
kubectl run test --rm -it --image=busybox -- /bin/sh

Inside pod:

wget -qO- http://service-name:port
📦 4. Endpoints (Critical Check)
kubectl get endpoints <service-name>

👉 If EMPTY → service not linked to pods ❌

☸️ 5. Pod Level Checks
kubectl get pods
kubectl describe pod <pod>

Check:

Running or CrashLoopBackOff
readiness/liveness probe failures
Logs
kubectl logs <pod>
kubectl logs -f <pod>
🔌 6. Container / App Level
kubectl exec -it <pod> -- /bin/sh

Inside container:

curl localhost:<app-port>

👉 If fails → app not running ❌

🧠 7. Network Policies
kubectl get networkpolicy

👉 Blocking traffic between:

ingress → service
service → pod
🔥 8. Node / Cluster Level
kubectl get nodes
kubectl describe node <node>

Check:

node ready?
resource pressure?
📊 9. Resource Issues
kubectl top pods
kubectl top nodes

👉 Look for:

CPU throttling
memory OOM
🔐 10. TLS / Certificates
expired cert → HTTPS fails
wrong secret in ingress
kubectl describe secret <tls-secret>
🧪 11. Quick Isolation Tests
Port-forward directly to pod
kubectl port-forward pod/<pod> 8080:80

👉 If this works:

problem is Ingress / Service
🚨 Common Root Causes
Layer	Issue
DNS	wrong record
Ingress	wrong routing
Service	selector mismatch
Endpoints	empty
Pod	crashing
App	not listening
NetworkPolicy	blocking traffic

⚡ Golden Debug Flow
DNS → LoadBalancer → Ingress → Service → Endpoints → Pod → App
🚀 Real-world quick commands
kubectl get pods
kubectl get svc
kubectl get ingress
kubectl get endpoints
kubectl logs <pod>
kubectl describe pod <pod>
🧠 Pro Tip
If port-forward works → issue is networking (Ingress/Service)
If port-forward fails → issue is pod/app
✅ Quick Checklist
✔ DNS resolves
✔ LB reachable
✔ Ingress routes correctly
✔ Service selectors match
✔ Endpoints not empty
✔ Pods healthy
✔ App responding