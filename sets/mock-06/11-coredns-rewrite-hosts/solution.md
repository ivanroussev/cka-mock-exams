```bash
kubectl -n kube-system get cm coredns -o jsonpath='{.data.Corefile}' > {{ANSWERS}}/Corefile.bak
kubectl -n kube-system edit cm coredns
```
Add inside the `.:53 { … }` block (e.g. right after `ready`):
```
    rewrite name exact db.legacy.internal postgres.data.svc.cluster.local
    hosts {
       10.20.30.40 registry.corp.internal
       fallthrough
    }
```
```bash
kubectl -n kube-system rollout restart deploy coredns     # or wait for the `reload` plugin (up to ~2 min incl. ConfigMap sync)
kubectl -n kube-system logs -l k8s-app=kube-dns --tail=5  # look for "plugin/errors" or Corefile syntax errors
kubectl run t --rm -it --image=busybox:1.37 --restart=Never -- nslookup db.legacy.internal
kubectl run t --rm -it --image=busybox:1.37 --restart=Never -- nslookup registry.corp.internal
```
Docs: *Customizing DNS Service*, and the CoreDNS plugin pages for `rewrite` and `hosts` (coredns.io isn't on the exam's allowed list —
the Kubernetes page shows the Corefile layout).
**Pitfalls:** `rewrite` must point at the **fully qualified** Service name. Without `fallthrough`, the `hosts` plugin answers
NXDOMAIN for every other name in the zones it covers — with no zone given that's *all* names, which breaks the cluster's DNS.
If CoreDNS crash-loops after your edit, restore the backup.
