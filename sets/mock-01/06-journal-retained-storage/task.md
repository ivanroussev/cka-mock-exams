The `journal` app in namespace `notes` needs storage whose data survives both pod restarts and an accidental PVC deletion.

1. Create a StorageClass `retain-local` that uses the provisioner `rancher.io/local-path`, has reclaim policy **Retain**,
   and binds volumes only once a pod uses them (**WaitForFirstConsumer**). Don't make it the default class.
2. In namespace `notes`, create a PVC `journal-data` requesting **256Mi**, access mode `ReadWriteOnce`, from StorageClass `retain-local`.
3. Create a Deployment `journal` (1 replica, image `nginx:1.27-alpine`) that mounts the PVC at `/usr/share/nginx/html`.
4. Write the text `journal v1` into the file `index.html` on that volume, so it is still there after the pod is replaced.
