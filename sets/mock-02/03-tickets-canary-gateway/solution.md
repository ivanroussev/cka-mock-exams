```bash
kubectl config use-context main
kubectl label ns tickets gateway-access=public
kubectl -n infra edit gateway public-gw
```
```yaml
  listeners:
  - name: http
    ...
    allowedRoutes:
      namespaces:
        from: Selector
        selector:
          matchLabels:
            gateway-access: public
```
HTTPRoute (docs: gateway-api.sigs.k8s.io → "HTTP header matching" and "HTTP traffic splitting"):
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata: {name: tickets, namespace: tickets}
spec:
  parentRefs:
  - name: public-gw
    namespace: infra            # the Gateway lives in another namespace
    sectionName: http
  hostnames: ["tickets.example.test"]
  rules:
  - matches:
    - headers:
      - name: X-Canary
        value: always
    backendRefs:
    - {name: tickets-v2, port: 80}
  - backendRefs:
    - {name: tickets-v1, port: 80, weight: 90}
    - {name: tickets-v2, port: 80, weight: 10}
```
```bash
kubectl -n tickets describe httproute tickets     # Parents → Accepted: True
```
**Pitfalls:** without `namespace: infra` in `parentRefs` the route looks for a Gateway in its own namespace. If the
Gateway doesn't admit the namespace, the route's status says `NotAllowedByListeners`. A rule with header matches is more
specific than one without, so the canary rule wins regardless of order. Weights are relative (90/10 = 9/1).
