```bash
kubectl config use-context main
kubectl -n storefront expose deploy cart --name cart --port 8080 --target-port 80
```
Gateway and HTTPRoute (docs: gateway-api.sigs.k8s.io → "HTTP routing", or kubernetes.io → "Gateway API"):
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata: {name: shop-gw, namespace: storefront}
spec:
  gatewayClassName: eg
  listeners:
  - name: http
    protocol: HTTP
    port: 80
    hostname: shop.example.test
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata: {name: shop, namespace: storefront}
spec:
  parentRefs:
  - name: shop-gw
  hostnames: ["shop.example.test"]
  rules:
  - matches:
    - path: {type: PathPrefix, value: /cart}
    backendRefs:
    - {name: cart, port: 8080}
  - backendRefs:                 # no match = PathPrefix "/"
    - {name: catalog, port: 80}
```
```bash
kubectl -n storefront get gateway shop-gw          # PROGRAMMED True once the LoadBalancer address is assigned
kubectl -n storefront describe httproute shop      # Accepted / ResolvedRefs True
```
**Notes:** the `backendRefs` port is the **Service** port (8080), not the container port. The most specific path wins,
so the order of the rules doesn't matter. If `ResolvedRefs` is False, a backend Service name or port is wrong.
