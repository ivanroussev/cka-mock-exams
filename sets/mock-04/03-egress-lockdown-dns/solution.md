```bash
kubectl config use-context main
kubectl -n orders logs deploy/order-worker --tail=3        # inventory unreachable
kubectl -n orders get netpol egress-lockdown -o yaml
kubectl -n orders exec deploy/order-worker -- curl -sv -m3 http://inventory.stock:8080
#   Could not resolve host  → DNS (UDP/TCP 53 to kube-dns) is not allowed
kubectl -n stock get svc inventory      # 8080 → targetPort 80
kubectl -n orders edit netpol egress-lockdown
```
```yaml
  egress:
  - to:
    - namespaceSelector: {matchLabels: {kubernetes.io/metadata.name: stock}}
      podSelector: {matchLabels: {app: inventory}}
    ports:
    - {protocol: TCP, port: 80}          # the POD port, not the Service port 8080
  - to:
    - namespaceSelector: {matchLabels: {kubernetes.io/metadata.name: kube-system}}
      podSelector: {matchLabels: {k8s-app: kube-dns}}
    ports:
    - {protocol: UDP, port: 53}
    - {protocol: TCP, port: 53}
```
**Two faults:** an egress default-deny also blocks DNS, so names stop resolving; and NetworkPolicies see traffic *after* the Service has
translated it, so `ports` must name the container port (80), not the Service port (8080). Docs: "Network Policies" (examples) and
"DNS for Services and Pods".
