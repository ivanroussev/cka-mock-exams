There are **three** independent faults; fixing one only changes the error message, so keep reading the logs.

```bash
kubectl -n ledger logs deploy/teller --tail=3     # "bad address 'accounts'"  → DNS
kubectl -n ledger get deploy teller -o yaml | grep dnsPolicy      # Default = node's resolv.conf, no cluster DNS
kubectl -n ledger patch deploy teller -p '{"spec":{"template":{"spec":{"dnsPolicy":"ClusterFirst"}}}}'

kubectl -n ledger logs deploy/teller --tail=3     # now "timed out" / "connection refused"
kubectl -n ledger get endpointslices -l kubernetes.io/service-name=accounts   # PORTS 8080, but the pods listen on 9090
kubectl -n ledger get pod -l app=accounts -o jsonpath='{.items[0].spec.containers[0].ports}'   # name "web", 9090
kubectl -n ledger edit svc accounts               # targetPort: web   (or 9090)

kubectl -n ledger get netpol                      # read all four
kubectl -n ledger edit netpol teller-egress       # egress port 8080 → 9090
kubectl -n ledger logs deploy/teller --tail=2     # OK accounts: balance service ok
```
**Why:** NetworkPolicies are evaluated *after* the Service has been translated to a pod IP and port, so a policy must use the
**container port** (9090), never the Service port (8080). `dnsPolicy: Default` doesn't mean "the default" — the default is `ClusterFirst`.
