Earlier today an etcd snapshot of cluster `alt` was saved to `/opt/etcd-backup/inventory.db` on node `cka-alt-control-plane`.
Since then, someone deleted ConfigMaps in namespace `inventory` by mistake.

Restore cluster `alt` from that snapshot:

- restore the snapshot into the data directory `/var/lib/etcd-restored` on `cka-alt-control-plane`,
- make the cluster's etcd use that directory,
- make sure the API server serves the restored data.

Afterwards ConfigMaps `price-rules` and `warehouse-map` must be back in namespace `inventory`.
