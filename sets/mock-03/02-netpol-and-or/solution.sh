# Retry API calls: on a busy laptop the API server sometimes times out the TLS handshake.
retry() { wait_for 180 "$@"; }
apply() { local f; f=$(mktemp); cat > "$f"; retry kubectl --context "$1" apply -f "$f"; local r=$?; rm -f "$f"; return $r; }
apply main <<'YAML'
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: {name: ledger-ingress, namespace: payments}
spec:
  podSelector: {matchLabels: {app: ledger}}
  policyTypes: [Ingress]
  ingress:
  - from:
    - namespaceSelector: {matchLabels: {kubernetes.io/metadata.name: monitoring}}
      podSelector: {matchLabels: {app: prometheus}}
    - podSelector: {matchLabels: {role: api}}
    ports: [{protocol: TCP, port: 80}]
YAML
sleep 5
