```bash
kubectl config use-context main
kubectl -n storefront logs deploy/frontend --tail=2       # could not resolve catalog
kubectl -n storefront exec deploy/frontend -- cat /etc/resolv.conf     # nameserver 10.96.0.53 — nothing listens there
kubectl -n kube-system get svc kube-dns                   # the real cluster DNS: 10.96.0.10
kubectl -n kube-system get svc kube-dns -o jsonpath='{.spec.clusterIP}' > {{ANSWERS}}/cluster-dns-ip.txt
kubectl -n storefront edit deploy frontend
```
```yaml
    spec:
      dnsPolicy: ClusterFirst          # was None
      dnsConfig:                       # merged with the generated config for ClusterFirst
        searches:
        - inventory.svc.cluster.local
```
```bash
kubectl -n storefront exec deploy/frontend -- cat /etc/resolv.conf
#   search storefront.svc.cluster.local svc.cluster.local cluster.local inventory.svc.cluster.local
kubectl -n storefront logs deploy/frontend --tail=2       # catalog: 1204 products
```
**Notes:** with `dnsPolicy: None` the pod gets *only* what `dnsConfig` says. With `ClusterFirst`, `dnsConfig.searches` and `options` are
appended to the generated settings — the right way to add a search domain. Docs: "DNS for Services and Pods → Pod's DNS Config".
