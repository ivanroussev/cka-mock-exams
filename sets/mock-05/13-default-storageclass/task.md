The team wants dynamically provisioned volumes to survive the deletion of their claims by default.

1. Create a StorageClass `local-retain` that uses the same provisioner as the existing class `standard`, keeps volumes after their claim
   is deleted, and only provisions a volume once a pod using the claim is scheduled.
2. Make `local-retain` the cluster's **default** StorageClass. `standard` must stay, but no longer be the default.
3. In namespace `lab-sc`, create a PVC `scratch` requesting `200Mi` (`ReadWriteOnce`) **without** naming a StorageClass, and a Pod
   `scratch-writer` (image `busybox:1.37`, command `sleep infinity`) that mounts it at `/scratch`.
