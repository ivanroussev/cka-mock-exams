Context: `main`

Deployment `edge-web` (2 replicas, httpd on port 80) runs in namespace `edge`.

1. Expose it with a Service named `edge-public` of type **LoadBalancer** on port 80. When the cluster has assigned the Service an external
   address, write that IP address (only the IP) to `{{ANSWERS}}/edge-public-ip.txt`.
2. Create a **headless** Service named `edge-peers` in namespace `edge` on port 80 for the same Pods, so that a DNS lookup of
   `edge-peers.edge.svc.cluster.local` returns the individual Pod IPs.
