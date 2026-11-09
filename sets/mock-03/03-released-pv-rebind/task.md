In namespace `records`, someone deleted the PersistentVolumeClaim `archive-data` by mistake. Its PersistentVolume `records-archive` was kept
(reclaim policy `Retain`) and still holds the data, but it is now `Released`.

1. Make the PV usable again **without** deleting or recreating it, and keep its reclaim policy `Retain`.
2. Create a PVC `archive-data` in namespace `records` (storage class `archive`, `ReadWriteOnce`, `2Gi`) that binds to `records-archive`.
3. Create a Pod `archive-reader` in namespace `records` (image `busybox:1.37`, command `sleep 3600`) that mounts the claim **read-only** at `/archive`.
