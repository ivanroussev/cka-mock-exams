```bash
ssh cka-alt-control-plane
cat /etc/kubernetes/manifests/etcd.yaml | grep -E 'cert|key|trusted|listen-client|data-dir|path:'
etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key \
  snapshot save /var/lib/etcd-backup/post-migration.db
etcdutl snapshot status /var/lib/etcd-backup/pre-migration.db -w table
etcdutl snapshot restore /var/lib/etcd-backup/pre-migration.db --data-dir /var/lib/etcd-restored
vim /etc/kubernetes/manifests/etcd.yaml
#   volumes:
#   - hostPath:
#       path: /var/lib/etcd-restored        ← was /var/lib/etcd  (the etcd-data volume)
#       type: DirectoryOrCreate
#     name: etcd-data
# (Alternatively change --data-dir AND the mountPath AND the hostPath consistently.)
watch crictl ps                          # etcd and kube-apiserver restart (1–2 min)
exit
kubectl config use-context alt
kubectl -n platform-config get cm        # feature-flags, rate-limits, routing-table
```
**Notes:** `etcdctl snapshot save` talks to the running server (needs endpoint + certs); `etcdutl snapshot restore` works offline on the
file and needs no certs. Changing only the hostPath is the least error-prone edit: the container still sees `/var/lib/etcd`.
After a restore, restart the control-plane components (`crictl stop` their containers) and **the kubelet on every node**:
their watches still carry resource versions from after the snapshot, so a worker may otherwise ignore pods bound to it.
Docs: "Operating etcd clusters for Kubernetes → Backing up / Restoring an etcd cluster".
