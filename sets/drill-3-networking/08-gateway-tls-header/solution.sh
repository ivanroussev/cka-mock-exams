kubectl --context main -n gw-api patch gateway api-gw --type=json -p='[{"op":"add","path":"/spec/listeners/-","value":
  {"name":"https","protocol":"HTTPS","port":443,"hostname":"api.example.com",
   "tls":{"mode":"Terminate","certificateRefs":[{"kind":"Secret","name":"api-tls"}]}}}]' >/dev/null
apply main <<'YAML'
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata: {name: api-route, namespace: gw-api}
spec:
  parentRefs: [{name: api-gw}]
  hostnames: [api.example.com]
  rules:
  - matches:
    - headers: [{name: X-Canary, value: always}]
    backendRefs: [{name: api-v2, port: 80}]
  - backendRefs: [{name: api-v1, port: 80}]
YAML
wait_for 120 bash -c "kubectl --context main -n gw-api get gateway api-gw -o json | jq -e '[.status.listeners[]? | select(.name==\"https\") | .conditions[] | select(.type==\"Programmed\" and .status==\"True\")] | length == 1'"
gw="$(kubectl --context main -n gw-api get gateway api-gw -o jsonpath='{.status.addresses[0].value}')"
wait_for 90 bash -c "kubectl --context main -n gw-api run sol-\$RANDOM --image=$IMG_CURL --restart=Never --rm -i --quiet --command -- curl -sk -m 5 --resolve api.example.com:443:$gw https://api.example.com/ | grep -q 'api v1'"
