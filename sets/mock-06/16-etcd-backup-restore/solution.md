Docs page: **"Operating etcd clusters for Kubernetes"** → *Backing up* and *Restoring an etcd cluster*.

```bash
# On cp1 — 1. backup (endpoint and cert paths: grep them from /etc/kubernetes/manifests/etcd.yaml)
mkdir -p /opt/backup
etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key \
  snapshot save /opt/backup/pre-cleanup.db

# 2. the "accident"
kubectl delete namespace payments

# 3. restore — stop the API server first so nothing writes to (or caches) the old data
mv /etc/kubernetes/manifests/kube-apiserver.yaml /etc/kubernetes/manifests/etcd.yaml /root/
crictl ps | grep -E 'etcd|apiserver'              # wait until both are gone
etcdutl snapshot restore /opt/backup/pre-cleanup.db --data-dir /var/lib/etcd-restore

vim /root/etcd.yaml        # volumes: etcd-data hostPath.path: /var/lib/etcd  →  /var/lib/etcd-restore
mv /root/etcd.yaml /etc/kubernetes/manifests/
mv /root/kube-apiserver.yaml /etc/kubernetes/manifests/

kubectl get --raw /readyz                          # may take a minute
systemctl restart kubelet                          # on cp1 and w1: re-sync pod status with the restored state
kubectl get ns payments; kubectl -n payments get cm,deploy
```

**Pitfalls:** changing only the `hostPath` is enough — the container still sees `/var/lib/etcd`, so `--data-dir` can stay.
If you also change `--data-dir`, change the `volumeMounts` `mountPath` to match. Restoring into the *existing*
`/var/lib/etcd` fails (`data-dir exists`). Restarting the API server after the restore avoids it serving stale cached objects.
Optional but correct: pass `--name cp1 --initial-cluster cp1=https://<ip>:2380 --initial-advertise-peer-urls https://<ip>:2380`
to `etcdutl snapshot restore` so the restored member keeps its identity.
