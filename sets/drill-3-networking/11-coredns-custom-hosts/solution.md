```bash
kubectl config use-context alt
kubectl -n kube-system get cm coredns -o yaml > coredns-backup.yaml     # always keep a backup
kubectl -n kube-system edit cm coredns
```
Add a `hosts` block inside the `.:53 { … }` server block (before `kubernetes` is a good spot):
```
    hosts {
       172.20.50.10 vault.corp.internal
       172.20.50.11 ldap.corp.internal
       fallthrough
    }
```
```bash
kubectl -n kube-system rollout restart deploy coredns      # or wait ~1–2 min for the reload plugin
kubectl -n kube-system get pods -l k8s-app=kube-dns          # Running? If CrashLoopBackOff: kubectl logs → syntax error
kubectl run t --rm -it --image=busybox:1.37 --restart=Never -- nslookup vault.corp.internal
```
**Pitfalls:** forgetting `fallthrough` in a plugin that owns a zone can swallow other names; a typo (missing brace) crashes CoreDNS and
takes all cluster DNS down — so back up first and watch the Pods after the change.
Alternative for a whole domain served by another DNS server: a separate server block `corp.internal:53 { forward . <dns-ip> }`.
