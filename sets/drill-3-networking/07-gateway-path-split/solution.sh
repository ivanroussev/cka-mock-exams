apply main <<'YAML'
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata: {name: shop-gw, namespace: gw-shop}
spec:
  gatewayClassName: eg
  listeners:
  - {name: http, protocol: HTTP, port: 80, hostname: shop.example.com}
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata: {name: shop-route, namespace: gw-shop}
spec:
  parentRefs: [{name: shop-gw}]
  hostnames: [shop.example.com]
  rules:
  - matches: [{path: {type: PathPrefix, value: /cart}}]
    backendRefs: [{name: cart, port: 80}]
  - backendRefs:
    - {name: store-v1, port: 80, weight: 80}
    - {name: store-v2, port: 80, weight: 20}
YAML
kubectl --context main -n gw-shop wait --for=condition=Programmed gateway/shop-gw --timeout=300s >/dev/null
wait_for 120 bash -c "[ -n \"\$(kubectl --context main -n gw-shop get gateway shop-gw -o jsonpath='{.status.addresses[0].value}')\" ]"
# give Envoy a moment to load the route
gw="$(kubectl --context main -n gw-shop get gateway shop-gw -o jsonpath='{.status.addresses[0].value}')"
wait_for 90 bash -c "kubectl --context main -n gw-shop run sol-\$RANDOM --image=$IMG_CURL --restart=Never --rm -i --quiet --command -- curl -s -m 5 -H 'Host: shop.example.com' http://$gw/cart | grep -q 'cart service'"
