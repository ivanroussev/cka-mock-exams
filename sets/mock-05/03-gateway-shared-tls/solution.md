Three objects in three namespaces: the Gateway (gw-infra), a **ReferenceGrant** next to the Secret (certs) and the HTTPRoute (shop-web).
Docs: gateway-api.sigs.k8s.io → *Guides → TLS* (cross-namespace certificate refs) and *API → ReferenceGrant*.

```bash
kubectl label ns shop-web shared-gw-access=true

cat <<'YAML' | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1beta1
kind: ReferenceGrant
metadata: {name: gw-infra-certs, namespace: certs}     # lives in the namespace of the *target*
spec:
  from: [{group: gateway.networking.k8s.io, kind: Gateway, namespace: gw-infra}]
  to:   [{group: "", kind: Secret, name: shop-wildcard}]
---
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata: {name: shared-gw, namespace: gw-infra}
spec:
  gatewayClassName: eg
  listeners:
  - name: https
    port: 443
    protocol: HTTPS
    hostname: "*.shop.internal"
    tls:
      mode: Terminate
      certificateRefs: [{kind: Secret, name: shop-wildcard, namespace: certs}]
    allowedRoutes:
      namespaces:
        from: Selector
        selector: {matchLabels: {shared-gw-access: "true"}}
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata: {name: storefront, namespace: shop-web}
spec:
  parentRefs: [{name: shared-gw, namespace: gw-infra, sectionName: https}]
  hostnames: [www.shop.internal]
  rules: [{backendRefs: [{name: storefront, port: 8080}]}]
YAML

kubectl -n gw-infra get gateway shared-gw                 # PROGRAMMED True
kubectl -n gw-infra describe gateway shared-gw            # listener ResolvedRefs True (False/RefNotPermitted = no ReferenceGrant)
kubectl -n blog-web get httproute blog -o yaml | grep -A3 reason   # NotAllowedByListeners
# test: the Envoy service is created in envoy-gateway-system
IP=$(kubectl -n envoy-gateway-system get svc -l gateway.envoyproxy.io/owning-gateway-name=shared-gw -o jsonpath='{.items[0].spec.clusterIP}')
kubectl run t --rm -it --image=curlimages/curl:8.11.1 --restart=Never -- curl -sk --resolve www.shop.internal:443:$IP https://www.shop.internal/
```
**Pitfalls:** the ReferenceGrant goes in the namespace that *owns the Secret*, not the Gateway's. The default `allowedRoutes`
is `from: Same`, so without the selector even `shop-web` couldn't attach. A Route in another namespace needs `namespace:` in its `parentRefs`.
