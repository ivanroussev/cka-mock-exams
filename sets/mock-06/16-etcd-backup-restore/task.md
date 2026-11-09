On the kubeadm cluster on `cp1` / `w1`, practise an etcd backup and restore. Work on `cp1` (`./cka ssh cp1`);
the etcd certificates are in `/etc/kubernetes/pki/etcd/`.

1. Take a snapshot of etcd with `etcdctl` and save it to `/opt/backup/pre-cleanup.db`.
2. Delete the namespace `payments` and wait until it is gone.
3. Restore the snapshot with `etcdutl` into the data directory `/var/lib/etcd-restore`, and make the etcd static pod on `cp1`
   use that directory.

Afterwards the cluster must be healthy and the namespace `payments` must be back with its original objects
(ConfigMap `ledger`, Deployment `ledger-api`).
