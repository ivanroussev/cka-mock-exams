Before the cluster on `cp1` / `w1` is touched any further, back up its etcd database.

1. On `cp1`, use `etcdctl` to save a snapshot of the etcd member running on `cp1` to `/opt/backup/etcd-snapshot.db`.
   The etcd certificates are in `/etc/kubernetes/pki/etcd/`.
2. Verify the snapshot with `etcdutl`, and write its **hash** and **revision** (any output format of
   `etcdutl snapshot status` is fine) to `/opt/backup/etcd-snapshot-status.txt` on `cp1`.

This question is independent of the upgrade in question 1 — do it before or after.
