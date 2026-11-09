# Retry API calls: on a busy laptop the API server sometimes times out the TLS handshake.
retry() { wait_for 180 "$@"; }
apply() { local f; f=$(mktemp); cat > "$f"; retry kubectl --context "$1" apply -f "$f"; local r=$?; rm -f "$f"; return $r; }
retry kubectl --context main label ns checkout edge-access=true --overwrite
retry kubectl --context main -n edge patch gateway edge-gw --type=json -p='[{"op":"add","path":"/spec/listeners/0/allowedRoutes","value":{"namespaces":{"from":"Selector","selector":{"matchLabels":{"edge-access":"true"}}}}}]'
apply main <<'YAML'
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata: {name: checkout, namespace: checkout}
spec:
  parentRefs:
  - {name: edge-gw, namespace: edge}
  hostnames: [checkout.shop.example]
  rules:
  - matches:
    - headers: [{name: X-Canary, value: "true"}]
    backendRefs:
    - {name: checkout-v2, port: 8080}
  - backendRefs:
    - {name: checkout-v1, port: 8080, weight: 90}
    - {name: checkout-v2, port: 8080, weight: 10}
YAML
wait_for 90 bash -c "[ \"\$(kubectl --context main -n checkout get httproute checkout -o jsonpath='{.status.parents[0].conditions[?(@.type==\"Accepted\")].status}')\" = True ]"
# Wait until Envoy has the route programmed.
wait_for 90 bash -c "svc=\$(kubectl --context main -n envoy-gateway-system get svc -l gateway.envoyproxy.io/owning-gateway-name=edge-gw -o jsonpath='{.items[0].metadata.name}');
  kubectl --context main -n edge run sol-\$RANDOM --image=$IMG_CURL --restart=Never --rm -i --quiet --command -- sh -c \"sleep 1; curl -s -m 3 -H 'Host: checkout.shop.example' -H X-Canary:true http://\$svc.envoy-gateway-system/\" | grep -q 'checkout v2'"
