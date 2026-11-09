source "$TASK_DIR/../lib.sh"
kubectl --context main label ns tickets gateway-access=public --overwrite
kubectl --context main -n infra patch gateway public-gw --type=json -p='[{"op":"replace","path":"/spec/listeners/0/allowedRoutes","value":{"namespaces":{"from":"Selector","selector":{"matchLabels":{"gateway-access":"public"}}}}}]'
apply main <<'YAML'
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata: {name: tickets, namespace: tickets}
spec:
  parentRefs:
  - {name: public-gw, namespace: infra, sectionName: http}
  hostnames: [tickets.example.test]
  rules:
  - matches:
    - headers: [{name: X-Canary, value: always}]
    backendRefs: [{name: tickets-v2, port: 80}]
  - backendRefs:
    - {name: tickets-v1, port: 80, weight: 90}
    - {name: tickets-v2, port: 80, weight: 10}
YAML
wait_for 240 bash -c "a=\$(gw_addr main infra public-gw) && curl_pod main tickets -H 'Host: tickets.example.test' -H 'X-Canary: always' http://\$a/ | grep -q 'tickets v2'"
