source "$TASK_DIR/../lib.sh"
kubectl --context main -n storefront expose deploy cart --name cart --port 8080 --target-port 80
apply main <<'YAML'
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata: {name: shop-gw, namespace: storefront}
spec:
  gatewayClassName: eg
  listeners:
  - {name: http, protocol: HTTP, port: 80, hostname: shop.example.test}
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata: {name: shop, namespace: storefront}
spec:
  parentRefs: [{name: shop-gw}]
  hostnames: [shop.example.test]
  rules:
  - matches: [{path: {type: PathPrefix, value: /cart}}]
    backendRefs: [{name: cart, port: 8080}]
  - matches: [{path: {type: PathPrefix, value: /}}]
    backendRefs: [{name: catalog, port: 80}]
YAML
kubectl --context main -n storefront wait gateway/shop-gw --for=condition=Accepted --timeout=180s
wait_for 120 bash -c "a=\$(gw_addr main storefront shop-gw) && curl_pod main storefront -H 'Host: shop.example.test' http://\$a/cart | grep -q cart"
