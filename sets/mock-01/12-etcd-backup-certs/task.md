Before a planned control-plane upgrade of cluster `alt`, do the usual safety steps on node `cka-alt-control-plane`:

1. Take a snapshot of the cluster's etcd and save it to `/opt/etcd-backup/pre-upgrade.db` **on the node**.
   etcd listens on `https://127.0.0.1:2379`; its certificates are in `/etc/kubernetes/pki/etcd/`.
2. Write the **revision** stored in that snapshot (as reported for the snapshot file) to `{{ANSWERS}}/etcd-snapshot-revision.txt`.
3. Write the **expiry date** of the kube-apiserver's serving certificate to `{{ANSWERS}}/apiserver-cert-expiry.txt`
   (as printed by `openssl` or by `kubeadm certs check-expiration`, e.g. `Nov  9 17:31:05 2027 GMT`).
