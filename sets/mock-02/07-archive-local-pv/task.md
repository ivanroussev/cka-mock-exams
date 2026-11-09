The `records` team keeps an archive on the local disk of node `cka-main-worker`, in directory `/srv/archive`. Make it available to a pod:

1. Create a StorageClass `manual-archive` with **no dynamic provisioner** (`kubernetes.io/no-provisioner`) and volume binding mode `WaitForFirstConsumer`.
2. Create a PersistentVolume `archive-pv`: **512Mi**, access mode `ReadWriteOnce`, reclaim policy **Retain**, StorageClass `manual-archive`,
   a **`local`** volume for path `/srv/archive`, usable only on node `cka-main-worker`.
3. In namespace `records`, create a PVC `archive-claim` requesting 512Mi from StorageClass `manual-archive`.
4. Create a Pod `archive-reader` in namespace `records` (image `nginx:1.27-alpine`) that mounts the claim **read-only** at `/usr/share/nginx/html`.

The pod must serve the existing `index.html` from the archive.
