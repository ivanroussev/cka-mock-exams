In namespace `reports-db`, Pod `db` (Redis with append-only persistence in `/data`) has been **Pending** since it was created.

1. Find out why and fix it so that `db` runs with its data on the PVC `db-data` (keep the names `db` and `db-data`, size `1Gi`).
   Use the cluster's existing dynamic provisioning; don't create PersistentVolumes by hand.
2. While you're at it, give `db` an additional **in-memory** scratch volume named `scratch`, limited to `64Mi`, mounted at `/scratch`.
