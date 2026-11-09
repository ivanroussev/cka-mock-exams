Docs: search "Network Policies" → *Default policies*. There is no imperative command for NetworkPolicies — copy YAML.
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: {name: deny-all, namespace: vault}
spec:
  podSelector: {}               # {} = every Pod in the namespace
  policyTypes: [Ingress, Egress] # listed type + no rules = deny that direction
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: {name: allow-dns, namespace: vault}
spec:
  podSelector: {}
  policyTypes: [Egress]
  egress:
  - to:
    - namespaceSelector:
        matchLabels: {kubernetes.io/metadata.name: kube-system}   # label every namespace gets automatically
    ports:
    - {protocol: UDP, port: 53}
    - {protocol: TCP, port: 53}
```
```bash
kubectl -n vault run t --rm -it --image=busybox:1.37 --restart=Never -- nslookup secrets-api   # works
kubectl -n vault run t --rm -it --image=busybox:1.37 --restart=Never -- wget -T 3 -qO- secrets-api   # times out
```
**Pitfalls:** `policyTypes: [Ingress]` alone doesn't touch egress. A default-deny egress policy also kills DNS, so almost every app
breaks until you add the port-53 rule — and DNS uses **UDP and TCP**. Policies are additive (a union), so `allow-dns` opens only DNS.
