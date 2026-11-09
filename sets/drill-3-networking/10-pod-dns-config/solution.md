```bash
kubectl config use-context main
kubectl -n dns-lab exec lookup -- cat /etc/resolv.conf     # nameserver 192.0.2.53, search corp.invalid → dnsPolicy: None
kubectl -n dns-lab get pod lookup -o yaml > lookup.yaml
```
Edit `lookup.yaml` (delete `status`, the `dnsPolicy: None` block), then `kubectl replace --force -f lookup.yaml`:
```yaml
spec:
  dnsPolicy: ClusterFirst          # the default: kube-dns Service + <ns>.svc.cluster.local search list
  dnsConfig:
    options: [{name: ndots, value: "2"}]   # merged into the generated resolv.conf
```
```bash
kubectl -n dns-lab exec lookup -- nslookup records
echo records.dns-lab.svc.cluster.local > {{ANSWERS}}/records-fqdn.txt
kubectl -n dns-lab get pod cache -o wide                     # e.g. 10.244.1.7
echo 10-244-1-7.dns-lab.pod.cluster.local > {{ANSWERS}}/cache-pod-dns.txt
kubectl -n dns-lab exec lookup -- nslookup 10-244-1-7.dns-lab.pod.cluster.local
```
**Know the formats:** Service `<svc>.<ns>.svc.cluster.local`; Pod `<ip-with-dashes>.<ns>.pod.cluster.local`.
`dnsPolicy: None` *requires* `dnsConfig` and ignores cluster DNS completely; `Default` (despite the name) uses the **node's** resolver,
not CoreDNS. `dnsConfig` is immutable on a running Pod → recreate it.
