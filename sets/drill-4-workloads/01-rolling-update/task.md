Deployment `storefront` in namespace `rollout` runs `nginx:1.27-alpine` with 4 replicas.

1. Change its rolling-update strategy so that during an update **at most 1 extra pod** is created and **no pod is ever unavailable**.
2. Update the container `nginx` to image `nginx:1.28-alpine`.
3. Record the change cause `upgrade nginx to 1.28` so that it appears in the CHANGE-CAUSE column of `kubectl rollout history` for the new revision.
4. Once the rollout has finished, write the Deployment's current revision number (just the number) to `{{ANSWERS}}/storefront-revision.txt`.
