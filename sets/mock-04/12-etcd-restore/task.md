A faulty migration script deleted and overwrote ConfigMaps in namespace `platform-config` of cluster `alt`. Before it ran, an etcd snapshot
was saved on `cka-alt-control-plane` at `/var/lib/etcd-backup/pre-migration.db`.

1. First, take a snapshot of the **current** etcd state to `/var/lib/etcd-backup/post-migration.db` on `cka-alt-control-plane` (for the post-mortem).
2. Restore etcd from `/var/lib/etcd-backup/pre-migration.db` into the new data directory `/var/lib/etcd-restored`, and make the etcd
   static pod use it.
3. Make sure the cluster is healthy afterwards: the API server answers, and the original ConfigMaps in `platform-config` are back.
