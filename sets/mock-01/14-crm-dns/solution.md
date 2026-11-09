```bash
kubectl config use-context main
kubectl -n crm exec deploy/crm-frontend -- cat /etc/resolv.conf     # nameserver 192.0.2.53 — not the cluster DNS
kubectl -n kube-system get svc kube-dns                              # 10.96.0.10
kubectl -n crm get deploy crm-frontend -o yaml | grep -A6 dnsPolicy  # dnsPolicy: None + custom dnsConfig
kubectl -n crm edit deploy crm-frontend      # dnsPolicy: ClusterFirst, delete the dnsConfig block
kubectl -n crm rollout status deploy crm-frontend
kubectl -n crm exec deploy/crm-frontend -- wget -qO- http://crm-db
echo crm-db.crm.svc.cluster.local > {{ANSWERS}}/crm-db-fqdn.txt
```
**Notes:** `dnsPolicy: None` ignores the cluster DNS completely and uses only `dnsConfig`. `ClusterFirst` (the default)
points pods at the kube-dns Service and adds the search domains `<ns>.svc.cluster.local svc.cluster.local cluster.local`
— that's why the short name `crm-db` works. Service FQDN: `<service>.<namespace>.svc.cluster.local`.
