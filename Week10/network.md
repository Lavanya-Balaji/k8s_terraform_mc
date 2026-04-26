
Network watcher logs: 
Cloud watcher logs to network troubleshooting 


tcpdump - Watching packets travel through the network

Debug connectivity issues

Check if traffic is reaching a host:

sudo tcpdump -i any host <IP>

Check if port is open / traffic hitting
sudo tcpdump -i any port 80

Kubernetes troubleshooting

Inside a pod/node:

Check if service → pod traffic is flowing
Verify ingress traffic reaching pods


Detect blocked traffic

If:

No packets seen → traffic not reaching
SYN sent but no response → firewall issue

sudo tcpdump -i any icmp 
tcpdump -i <interface> <filters>

sudo tcpdump -i any
Capture specific host

sudo tcpdump -i any host 10.0.0.5
Capture specific port
sudo tcpdump -i any port 443
save to file 
sudo tcpdump -i any -w capture.pcap 
read from a file 
tcpdump -r capture.pcap 


kubernetes context:

kubectl exec -it <pod> -- tcpdump -i any 

👉 Helps debug:

service routing
network policies
CNI issues 


Quick Summary
tcpdump = packet-level debugging tool
Used for network troubleshooting
Helps identify where traffic is failing
Works at very low level (L3/L4) 


Use wireshark to visual interpretation of hte data collected 

