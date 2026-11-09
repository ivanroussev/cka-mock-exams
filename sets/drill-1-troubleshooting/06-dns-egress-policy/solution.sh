apply main <<'YAML'
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: {name: checkout-allow-dns, namespace: orders}
spec:
  podSelector: {matchLabels: {app: checkout}}
  policyTypes: [Egress]
  egress:
  - to:
    - namespaceSelector: {matchLabels: {kubernetes.io/metadata.name: kube-system}}
      podSelector: {matchLabels: {k8s-app: kube-dns}}
    ports:
    - {protocol: UDP, port: 53}
    - {protocol: TCP, port: 53}
YAML
sleep 5
