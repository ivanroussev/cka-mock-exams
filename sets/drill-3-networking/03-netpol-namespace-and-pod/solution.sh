apply main <<'YAML'
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: {name: stock-ingress, namespace: inventory}
spec:
  podSelector:
    matchLabels: {app: stock-api}
  policyTypes: [Ingress]
  ingress:
  - from:
    - namespaceSelector:
        matchLabels: {team: shop}
      podSelector:
        matchLabels: {role: checkout}
    ports:
    - {protocol: TCP, port: 80}
YAML
