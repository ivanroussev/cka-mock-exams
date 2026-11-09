Docs: search "Services without selectors" (Service page) — it has both manifests.
```yaml
apiVersion: v1
kind: Service
metadata: {name: legacy-registry, namespace: legacy}
spec:                          # no selector → the EndpointSlice controller leaves this Service alone
  ports: [{name: http, port: 80, targetPort: 5000}]
---
apiVersion: discovery.k8s.io/v1
kind: EndpointSlice
metadata:
  name: legacy-registry-1
  namespace: legacy
  labels:
    kubernetes.io/service-name: legacy-registry   # this label links the slice to the Service
addressType: IPv4
ports: [{name: http, port: 5000, protocol: TCP}]   # name must match the Service port's name ("" if unnamed)
endpoints:
- addresses: ["<IP from legacy-backend.txt>"]
```
```bash
kubectl -n legacy run t --rm -it --image=curlimages/curl:8.11.1 --restart=Never -- curl -s legacy-registry.legacy/v2/
```
**Pitfalls:** forgetting the `kubernetes.io/service-name` label (the slice is then ignored), and a port *name* mismatch between the
Service port and the EndpointSlice port. The slice's port is the backend's real port (5000), not the Service port.
For a DNS name instead of an IP, use a Service of `type: ExternalName`.
