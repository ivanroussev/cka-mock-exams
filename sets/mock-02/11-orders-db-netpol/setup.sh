source "$TASK_DIR/../lib.sh"
ns main data
ns main orders
ns main marketing
kubectl --context main label ns marketing team=marketing --overwrite >/dev/null
echo_app main data orders-db "orders-db" 5432
kubectl --context main -n data expose deploy orders-db --port 5432 >/dev/null
apply main <<'YAML'
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: {name: deny-all-ingress, namespace: data}
spec:
  podSelector: {}
  policyTypes: [Ingress]
YAML
kubectl --context main -n data rollout status deploy/orders-db --timeout=120s >/dev/null
