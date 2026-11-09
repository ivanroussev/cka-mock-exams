# Retry API calls: on a busy laptop the API server sometimes times out the TLS handshake.
retry() { wait_for 180 "$@"; }
apply() { local f; f=$(mktemp); cat > "$f"; retry kubectl --context "$1" apply -f "$f"; local r=$?; rm -f "$f"; return $r; }
for i in $(seq 1 36); do IP=$(kubectl --context main -n erp get pod erp-legacy -o jsonpath='{.status.podIP}' 2>/dev/null) && [ -n "$IP" ] && break; sleep 5; done
echo "$IP" > "$ANSWERS/erp-ip.txt"
apply main <<YAML
apiVersion: v1
kind: Service
metadata: {name: erp, namespace: erp}
spec:
  ports: [{protocol: TCP, port: 80, targetPort: 80}]
---
apiVersion: discovery.k8s.io/v1
kind: EndpointSlice
metadata:
  name: erp-1
  namespace: erp
  labels: {kubernetes.io/service-name: erp}
addressType: IPv4
ports: [{protocol: TCP, port: 80}]
endpoints:
- addresses: ["$IP"]
---
apiVersion: v1
kind: Service
metadata: {name: erp-gateway, namespace: finance}
spec:
  type: ExternalName
  externalName: erp.erp.svc.cluster.local
YAML
sleep 3
