```bash
kubectl config use-context main
kubectl -n corp-dns get svc corp-dns              # note the CLUSTER-IP, e.g. 10.96.123.45
kubectl -n kube-system edit cm coredns
```
Add a **new server block** after the existing `.:53 { … }` block:
```
corp.internal:53 {
    errors
    cache 30
    forward . 10.96.123.45        # the corp-dns ClusterIP — forward needs an IP, not a name
}
```
```bash
kubectl -n kube-system rollout restart deploy coredns     # or wait ~1 min for the reload plugin
kubectl run t --rm -it --image=busybox:1.37 --restart=Never -- nslookup vault.corp.internal
echo 10.40.0.37 > {{ANSWERS}}/vault-ip.txt
```
**Why a separate block:** CoreDNS picks the server block with the most specific zone, so `corp.internal` queries go to the new block and
everything else keeps using `.:53`. Putting a second `forward` inside `.:53` would break cluster-external resolution (only one forward per block).
Docs: "Customizing DNS Service → Configuration of Stub-domain and upstream nameserver using CoreDNS".
