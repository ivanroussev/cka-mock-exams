```bash
kubectl config use-context main
kubectl -n payments get netpol ledger-ingress -o yaml
kubectl -n payments edit netpol ledger-ingress
```
```yaml
  ingress:
  - from:
    - namespaceSelector:                       # ONE entry: namespace AND pod label
        matchLabels: {kubernetes.io/metadata.name: monitoring}
      podSelector:
        matchLabels: {app: prometheus}
    - podSelector:                             # second entry: same namespace, role=api
        matchLabels: {role: api}
    ports:
    - {protocol: TCP, port: 80}
```
Test: `kubectl -n monitoring run t --rm -it --image=curlimages/curl:8.11.1 -l app=prometheus --restart=Never -- curl -m3 ledger.payments`

**The pitfall:** each `-` under `from:` is a separate rule, OR-ed together. `- namespaceSelector` followed by `- podSelector` means
"anything in monitoring **or** app=prometheus pods in *this* namespace". Putting both selectors in the *same* list item ANDs them.
A `podSelector` alone always means the policy's own namespace. Docs: "Network Policies → Behavior of to and from selectors".
