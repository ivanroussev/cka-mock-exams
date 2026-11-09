StatefulSet `quorum` in namespace `consensus` stores its data on PVCs of StorageClass `standard`, whose volumes are deleted together with
their claims. The team wants volumes that survive a deleted claim.

1. Create StorageClass `local-retain`: provisioner `rancher.io/local-path`, reclaim policy `Retain`, binding mode `WaitForFirstConsumer`.
   It must **not** become the default StorageClass.
2. Change `quorum` so that all 3 replicas use claims of StorageClass `local-retain` (keep the claim template name `data`, size `1Gi`).
   The existing data doesn't need to be kept. Afterwards, no PVC of StorageClass `standard` may remain in namespace `consensus`.
