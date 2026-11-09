apply main <<'YAML'
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: {name: default-deny, namespace: ledger}
spec:
  podSelector: {}
  policyTypes: [Ingress, Egress]
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: {name: api-egress, namespace: ledger}
spec:
  podSelector: {matchLabels: {app: ledger-api}}
  policyTypes: [Egress]
  egress:
  - to:
    - podSelector: {matchLabels: {app: ledger-db}}
    ports: [{protocol: TCP, port: 80}]
  - to:
    - namespaceSelector: {matchLabels: {kubernetes.io/metadata.name: kube-system}}
      podSelector: {matchLabels: {k8s-app: kube-dns}}
    ports: [{protocol: UDP, port: 53}, {protocol: TCP, port: 53}]
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: {name: db-ingress, namespace: ledger}
spec:
  podSelector: {matchLabels: {app: ledger-db}}
  policyTypes: [Ingress]
  ingress:
  - from:
    - podSelector: {matchLabels: {app: ledger-api}}
    ports: [{protocol: TCP, port: 80}]
YAML
sleep 5
