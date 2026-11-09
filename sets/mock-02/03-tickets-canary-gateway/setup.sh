source "$TASK_DIR/../lib.sh"
ensure_envoy_gateway main
ns main infra
ns main tickets
apply main <<'YAML'
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata: {name: public-gw, namespace: infra}
spec:
  gatewayClassName: eg
  listeners:
  - name: http
    protocol: HTTP
    port: 80
    hostname: "*.example.test"
    allowedRoutes:
      namespaces: {from: Same}
YAML
echo_app main tickets tickets-v1 "tickets v1"
echo_app main tickets tickets-v2 "tickets v2"
kubectl --context main -n tickets expose deploy tickets-v1 --port 80 >/dev/null
kubectl --context main -n tickets expose deploy tickets-v2 --port 80 >/dev/null
kubectl --context main -n infra wait gateway/public-gw --for=condition=Accepted --timeout=180s >/dev/null
kubectl --context main -n tickets rollout status deploy/tickets-v1 --timeout=120s >/dev/null
kubectl --context main -n tickets rollout status deploy/tickets-v2 --timeout=120s >/dev/null
