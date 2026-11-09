The pod of Deployment `uploader` in namespace `uploads` is stuck in `Pending`, and so is its PersistentVolumeClaim `uploads-data`.

1. Find out why the claim can't be provisioned and fix it. The claim must keep its name, its size `2Gi` and StorageClass `standard`.
   Only a **single pod** in the whole cluster may ever use this volume at the same time — use the access mode that enforces that.
2. Because of that access mode, a rolling update of `uploader` would hang (the new pod can't mount the volume while the old one holds it).
   Change the Deployment's update strategy so rollouts complete.

At the end, `uploader` must be running with the claim mounted.
