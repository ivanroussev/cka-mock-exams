```bash
kubectl config use-context main
kubectl label ns checkout edge-access=true
kubectl -n edge edit gateway edge-gw
```
```yaml
  listeners:
  - name: http
    protocol: HTTP
    port: 80
    allowedRoutes:
      namespaces:
        from: Selector
        selector:
          matchLabels: {edge-access: "true"}
```
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata: {name: checkout, namespace: checkout}
spec:
  parentRefs:
  - name: edge-gw
    namespace: edge              # cross-namespace parent: must be explicit
  hostnames: ["checkout.shop.example"]
  rules:
  - matches:
    - headers:
      - {name: X-Canary, value: "true"}
    backendRefs:
    - {name: checkout-v2, port: 8080}
  - backendRefs:                 # no matches = default PathPrefix "/"
    - {name: checkout-v1, port: 8080, weight: 90}
    - {name: checkout-v2, port: 8080, weight: 10}
```
```bash
kubectl -n checkout get httproute checkout -o yaml | grep -A5 conditions      # Accepted: True
SVC=$(kubectl -n envoy-gateway-system get svc -l gateway.envoyproxy.io/owning-gateway-name=edge-gw -o name | cut -d/ -f2)
kubectl -n edge run t --rm -it --image=curlimages/curl:8.11.1 --restart=Never -- \
  sh -c "for i in 1 2 3 4 5 6 7 8 9 10; do curl -s -H 'Host: checkout.shop.example' $SVC.envoy-gateway-system; done"
```
**Pitfalls:** by default a listener only accepts routes from its own namespace (`from: Same`) — the route then shows `Accepted: False, NotAllowedByListeners`.
Header matches are more specific than the catch-all rule, so the canary rule wins for those requests. Weights are relative (9/1 works too).
Docs: gateway-api.sigs.k8s.io → "HTTP traffic splitting" and "Cross-Namespace routing".
