for n in payments monitoring sandbox; do ns main $n; done
apply main <<YAML
apiVersion: v1
kind: Pod
metadata: {name: ledger, namespace: payments, labels: {app: ledger}}
spec:
  containers: [{name: ledger, image: $IMG_NGINX, ports: [{containerPort: 80}]}]
---
apiVersion: v1
kind: Service
metadata: {name: ledger, namespace: payments}
spec:
  selector: {app: ledger}
  ports: [{port: 80, targetPort: 80}]
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: {name: default-deny-ingress, namespace: payments}
spec:
  podSelector: {}
  policyTypes: [Ingress]
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: {name: ledger-ingress, namespace: payments}
spec:
  podSelector: {matchLabels: {app: ledger}}
  policyTypes: [Ingress]
  ingress:
  - from:
    - namespaceSelector: {matchLabels: {kubernetes.io/metadata.name: monitoring}}
    - podSelector: {matchLabels: {app: prometheus}}
    ports: [{protocol: TCP, port: 80}]
YAML
kubectl --context main -n payments wait --for=condition=Ready pod/ledger --timeout=120s >/dev/null
