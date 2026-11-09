The colleague's policy has **two** entries under `from` (note the two dashes) — they are OR-ed:
"any Pod in a `team=shop` namespace" **or** "any `role=checkout` Pod in `inventory` itself". And there is no `ports`, so 9090 is open too.
```bash
kubectl config use-context main
kubectl -n inventory get netpol stock-ingress -o yaml
kubectl get ns --show-labels
kubectl -n inventory edit netpol stock-ingress
```
```yaml
  ingress:
  - from:
    - namespaceSelector:          # ONE element with both selectors = AND
        matchLabels: {team: shop}
      podSelector:                # no dash here!
        matchLabels: {role: checkout}
    ports:
    - {protocol: TCP, port: 80}
```
Test: `kubectl -n storefront run t --rm -it --image=curlimages/curl:8.11.1 --restart=Never -l role=checkout -- curl -m 3 stock-api.inventory`
(works) and the same with `-l role=browser` or `:9090` (times out).

**Pitfall:** `- namespaceSelector` / `- podSelector` (two list items) is OR; `- namespaceSelector` + `  podSelector` (same item) is AND.
A `podSelector` without a `namespaceSelector` only matches Pods in the policy's own namespace.
