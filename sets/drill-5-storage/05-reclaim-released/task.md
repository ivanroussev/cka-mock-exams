PersistentVolume `archive-pv` still holds important data (`report.txt`), but its old claim was deleted and the PV is now **Released**.

1. Make the PV usable again **without deleting it** and without losing the data. Its reclaim policy must stay `Retain`.
2. In namespace `archive`, create a PVC named `archive-claim` (1Gi, `ReadWriteOnce`) that binds to `archive-pv`.
3. Create a Pod `archive-reader` in namespace `archive` (image `busybox:1.37`, command `sleep 3600`) that mounts the claim at `/archive`.
