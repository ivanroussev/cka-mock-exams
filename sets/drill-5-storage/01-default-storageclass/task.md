1. Create a StorageClass named `local-fast` with:
   - provisioner `rancher.io/local-path`
   - reclaim policy `Retain`
   - volume binding mode `WaitForFirstConsumer`
   - volume expansion allowed
2. Make `local-fast` the cluster's **default** StorageClass. `standard` must no longer be a default.
3. In namespace `sc-default`, create a PVC named `scratch` requesting `100Mi`, access mode `ReadWriteOnce`, **without** setting
   a storage class in it. It should end up using `local-fast`. (It may stay Pending — no pod uses it yet.)
