On cluster `alt`, someone made a bad change in namespace `etcd-drill`. An etcd snapshot taken just **before** the change
is at `/opt/backups/etcd-pre-change.db` on node `cka-alt-control-plane`. etcd's certificates are in `/etc/kubernetes/pki/etcd/`.

1. First, take a snapshot of the **current** etcd data and save it as `/opt/backups/etcd-now.db` on `cka-alt-control-plane`.
2. Restore `/opt/backups/etcd-pre-change.db` into the new data directory `/var/lib/etcd-restored`
   and make the cluster's etcd run from that directory.

When you are done, ConfigMap `app-settings` in `etcd-drill` must exist again and ConfigMap `debug-override` must be gone,
and the cluster must be fully working.
