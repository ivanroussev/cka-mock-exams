Docs: search **"Operating etcd clusters"** → *Backing up an etcd cluster* / *Restoring an etcd cluster*.
```bash
ssh cka-alt-control-plane                            # here: ./cka ssh cka-alt-control-plane
# The endpoint and cert paths are in the etcd manifest:
grep -E 'listen-client|cert-file|key-file|trusted-ca|data-dir' /etc/kubernetes/manifests/etcd.yaml

# 1. Backup
ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  snapshot save /opt/backups/etcd-now.db
etcdutl snapshot status /opt/backups/etcd-now.db -w table

# 2. Restore
mv /etc/kubernetes/manifests/kube-apiserver.yaml /etc/kubernetes/      # stop the API server first
etcdutl snapshot restore /opt/backups/etcd-pre-change.db --data-dir /var/lib/etcd-restored
vim /etc/kubernetes/manifests/etcd.yaml
#   volumes:
#   - hostPath:
#       path: /var/lib/etcd-restored      ← only the hostPath of the etcd-data volume changes
#       type: DirectoryOrCreate
#     name: etcd-data
watch crictl ps                                      # wait for a new etcd container (~30–60 s)
mv /etc/kubernetes/kube-apiserver.yaml /etc/kubernetes/manifests/
exit
kubectl -n etcd-drill get cm                         # app-settings back, debug-override gone
kubectl get nodes
```
**Pitfalls:** `etcdctl snapshot save` needs all three TLS flags plus `--endpoints`; `etcdutl snapshot restore` works offline on the file
(no certs). Changing only the `hostPath` keeps `--data-dir` and the `mountPath` as they were; if you change `--data-dir` instead, change the
`mountPath` *and* `hostPath` with it. Stop the API server before restoring, or restart it afterwards: otherwise its cache can keep
serving objects that no longer exist in etcd. If the API is slow to come back, restart kube-controller-manager and kube-scheduler too.
