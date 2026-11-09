kubectl --context main label ns orders team=orders --overwrite
apply main <<'YAML'
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: {name: allow-orders-api, namespace: data}
spec:
  podSelector: {matchLabels: {app: orders-db}}
  policyTypes: [Ingress]
  ingress:
  - from:
    - namespaceSelector: {matchLabels: {team: orders}}
      podSelector: {matchLabels: {app: orders-api}}
    ports: [{protocol: TCP, port: 5432}]
YAML
sleep 5
