The policy allows egress to the inventory pods on TCP 80, but **not DNS**. The name `inventory` can't be resolved, so
the request fails before it is even sent. (Calling the Service's ClusterIP directly works — that's the giveaway.)
```bash
kubectl -n orders get netpol checkout-egress -o yaml
kubectl -n orders exec deploy/checkout -- curl -s -m 3 http://inventory          # fails: "Could not resolve host"
kubectl -n orders exec deploy/checkout -- curl -s -m 3 http://$(kubectl -n orders get svc inventory -o jsonpath='{.spec.clusterIP}')   # works
```
Add a second policy (policies are additive) that allows DNS to CoreDNS — docs: search "Network Policies":
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: {name: checkout-allow-dns, namespace: orders}
spec:
  podSelector: {matchLabels: {app: checkout}}
  policyTypes: [Egress]
  egress:
  - to:
    - namespaceSelector: {matchLabels: {kubernetes.io/metadata.name: kube-system}}
      podSelector: {matchLabels: {k8s-app: kube-dns}}
    ports:
    - {protocol: UDP, port: 53}
    - {protocol: TCP, port: 53}
```
(Adding the same `to`/`ports` block to `checkout-egress` itself is equally correct.)

**Pitfall:** every Egress policy needs a DNS rule (UDP **and** TCP 53) unless the clients only use IPs.
`namespaceSelector` and `podSelector` in the *same* `to` item are ANDed; as two separate items they are ORed.
