Docs: "Network Policies" (copy the default-deny and the full example).
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: {name: default-deny, namespace: ledger}
spec:
  podSelector: {}
  policyTypes: [Ingress, Egress]
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: {name: api-egress, namespace: ledger}
spec:
  podSelector:
    matchLabels: {app: ledger-api}
  policyTypes: [Egress]
  egress:
  - to:
    - podSelector:
        matchLabels: {app: ledger-db}
    ports:
    - {protocol: TCP, port: 80}
  - to:
    - namespaceSelector:
        matchLabels: {kubernetes.io/metadata.name: kube-system}
      podSelector:                       # same list item → AND
        matchLabels: {k8s-app: kube-dns}
    ports:
    - {protocol: UDP, port: 53}
    - {protocol: TCP, port: 53}
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: {name: db-ingress, namespace: ledger}
spec:
  podSelector:
    matchLabels: {app: ledger-db}
  policyTypes: [Ingress]
  ingress:
  - from:
    - podSelector:
        matchLabels: {app: ledger-api}
    ports:
    - {protocol: TCP, port: 80}
```
```bash
kubectl config use-context main
kubectl apply -f netpol.yaml
kubectl -n ledger run t --rm -it --image=busybox:1.37 --restart=Never -l app=ledger-api -- wget -qO- -T 3 ledger-db
```
**Pitfalls:** once egress is denied, *names stop resolving* — always add the DNS rule (UDP **and** TCP 53) or the
app fails with "bad address". Allowing api → db needs **two** policies: egress on the api side and ingress on the db side.
A bare `podSelector` in `from`/`to` only matches pods in the policy's own namespace.
