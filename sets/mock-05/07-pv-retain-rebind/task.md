PersistentVolume `pv-archive` (reclaim policy `Retain`) still holds the 2019 ledger archive, but its claim was deleted by mistake
and the volume is now **Released**.

1. Make the volume usable again **without losing its data** and without changing its reclaim policy, and bind it to a new
   PersistentVolumeClaim `archive-restore` in namespace `records` (StorageClass `archive`, `ReadWriteOnce`, `1Gi`).
   The claim must bind to `pv-archive` and to no other volume.
2. Create a Pod `archive-reader` in namespace `records` (image `busybox:1.37`, command `sleep infinity`) that mounts the claim at `/archive`.

Check that `/archive/marker.txt` is readable from the pod.
