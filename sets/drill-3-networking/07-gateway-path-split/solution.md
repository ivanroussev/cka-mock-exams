Docs: search "Gateway API" → *HTTP routing* / *HTTP traffic splitting* on gateway-api.sigs.k8s.io (allowed in the exam), or the
Kubernetes "Gateway API" concept page.
```yaml
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
  - backendRefs:                     # no matches = default PathPrefix "/"
    - {name: store-v1, port: 80, weight: 80}
    - {name: store-v2, port: 80, weight: 20}
```
```bash
kubectl -n gw-shop get gateway shop-gw          # PROGRAMMED True, ADDRESS = the Gateway's IP
kubectl -n gw-shop describe httproute shop-route  # Accepted / ResolvedRefs conditions
kubectl -n gw-shop run t --rm -it --image=curlimages/curl:8.11.1 --restart=Never -- \
  curl -s -H 'Host: shop.example.com' http://<gateway-ip>/cart
```
**Notes:** weights are relative (80/20 = 4/1) and only apply *within* one rule. The most specific match wins regardless of rule order,
so `/cart` beats the catch-all. A route whose hostname doesn't match the listener's hostname is not attached (check `Accepted`).
