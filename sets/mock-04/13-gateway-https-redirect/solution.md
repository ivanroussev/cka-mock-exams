```bash
kubectl config use-context main
kubectl -n gateway-infra create secret tls secure-shop-tls --cert={{FILES}}/secure.crt --key={{FILES}}/secure.key
kubectl -n gateway-infra edit gateway public-gw
```
```yaml
  listeners:
  - {name: http, protocol: HTTP, port: 80}
  - name: https
    protocol: HTTPS
    port: 443
    hostname: secure.shop.example
    tls:
      mode: Terminate
      certificateRefs:
      - {kind: Secret, name: secure-shop-tls}
```
```yaml
apiVersion: gateway.networking.k8s.io/v1beta1
kind: ReferenceGrant                     # lives in the namespace of the TARGET (the Service)
metadata: {name: gateway-infra-to-storefront, namespace: shop-web}
spec:
  from:
  - {group: gateway.networking.k8s.io, kind: HTTPRoute, namespace: gateway-infra}
  to:
  - {group: "", kind: Service, name: storefront}
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata: {name: secure-shop, namespace: gateway-infra}
spec:
  parentRefs: [{name: public-gw, sectionName: https}]
  hostnames: ["secure.shop.example"]
  rules:
  - backendRefs: [{name: storefront, namespace: shop-web, port: 80}]
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata: {name: secure-shop-redirect, namespace: gateway-infra}
spec:
  parentRefs: [{name: public-gw, sectionName: http}]
  hostnames: ["secure.shop.example"]
  rules:
  - filters:
    - type: RequestRedirect
      requestRedirect: {scheme: https, statusCode: 301}
```
```bash
IP=$(kubectl -n envoy-gateway-system get svc -l gateway.envoyproxy.io/owning-gateway-name=public-gw -o jsonpath='{.items[0].spec.clusterIP}')
kubectl run t --rm -it --image=curlimages/curl:8.11.1 --restart=Never -- sh -c \
  "curl -sk --resolve secure.shop.example:443:$IP https://secure.shop.example/; curl -si --resolve secure.shop.example:80:$IP http://secure.shop.example/ | head -3"
```
**Pitfalls:** without the ReferenceGrant the route shows `ResolvedRefs: False (RefNotPermitted)` and Envoy returns 500.
`sectionName` pins a route to one listener — attach the redirect to *both* listeners and HTTPS clients loop forever.
Docs: gateway-api.sigs.k8s.io → "HTTP redirects and rewrites", "TLS", "ReferenceGrant".
