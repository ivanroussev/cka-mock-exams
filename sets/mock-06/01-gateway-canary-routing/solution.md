```bash
cat <<'YAML' | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata: {name: checkout, namespace: checkout}
spec:
  parentRefs: [{name: public, namespace: edge}]
  hostnames: [checkout.example.org]
  rules:
  - matches:
    - headers: [{name: X-Canary, value: always}]      # type Exact is the default
    backendRefs: [{name: checkout-v2, port: 80}]
  - backendRefs:                                     # no matches = path prefix "/"
    - {name: checkout-v1, port: 80, weight: 90}
    - {name: checkout-v2, port: 80, weight: 10}
YAML
kubectl -n checkout describe httproute checkout       # Accepted False: NotAllowedByListeners
kubectl -n edge get gateway public -o yaml            # no allowedRoutes → default "from: Same" (only namespace edge)

kubectl label ns checkout gateway-access=public
kubectl -n edge edit gateway public
#   listeners[0].allowedRoutes:
#     namespaces:
#       from: Selector
#       selector: {matchLabels: {gateway-access: public}}
kubectl -n checkout get httproute checkout -o jsonpath='{.status.parents[0].conditions[?(@.type=="Accepted")].status}'   # True

IP=$(kubectl -n envoy-gateway-system get svc -l gateway.envoyproxy.io/owning-gateway-name=public -o jsonpath='{.items[0].spec.clusterIP}')
kubectl run t --rm -it --image=curlimages/curl:8.11.1 --restart=Never -- \
  sh -c "for i in \$(seq 20); do curl -s -H 'Host: checkout.example.org' http://$IP/; done | sort | uniq -c"
```
Docs: gateway-api.sigs.k8s.io → *Guides → HTTP routing* / *Traffic splitting*, and *API → Gateway → AllowedRoutes*.
**Pitfalls:** the most specific match wins, so the header rule beats the catch-all rule regardless of order. Weights are relative
(90/10 = 9/1). `from: All` would also make the route work, but the task forbids opening the Gateway to every namespace.
