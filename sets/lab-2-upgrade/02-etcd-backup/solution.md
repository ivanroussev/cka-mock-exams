Docs page: **"Operating etcd clusters for Kubernetes"** → *Backing up an etcd cluster*.
The endpoint and certificate paths are in the etcd static pod manifest — look them up instead of guessing:

```bash
# On cp1
grep -E 'listen-client-urls|cert-file|key-file|trusted-ca-file' /etc/kubernetes/manifests/etcd.yaml

mkdir -p /opt/backup
etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  snapshot save /opt/backup/etcd-snapshot.db

etcdutl snapshot status /opt/backup/etcd-snapshot.db -w table | tee /opt/backup/etcd-snapshot-status.txt
```

**Pitfalls:** without the three TLS flags `etcdctl` hangs and times out (etcd only accepts client-certificate TLS).
`etcdctl snapshot status` is deprecated — offline work on a snapshot file (`status`, `restore`) belongs to `etcdutl`.
`ETCDCTL_API=3` is the default since etcd 3.4; setting it is harmless.
