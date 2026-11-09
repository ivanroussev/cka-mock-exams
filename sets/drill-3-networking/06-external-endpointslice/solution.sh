ip="$(cat "$FILES/legacy-backend.txt")"
apply main <<YAML
apiVersion: v1
kind: Service
metadata: {name: legacy-registry, namespace: legacy}
spec:
  ports: [{name: http, port: 80, targetPort: 5000}]
---
apiVersion: discovery.k8s.io/v1
kind: EndpointSlice
metadata:
  name: legacy-registry-1
  namespace: legacy
  labels: {kubernetes.io/service-name: legacy-registry}
addressType: IPv4
ports: [{name: http, port: 5000, protocol: TCP}]
endpoints:
- addresses: ["$ip"]
YAML
