*Warm-up.* Deployment `quote-api` in namespace `quotes` runs one replica of `nginx:1.27-alpine`.

1. Update its container `web` to the image `nginx:1.28-alpine`.
2. Scale it to **3** replicas.
3. Make `kubectl rollout history` show the change cause `upgrade to nginx 1.28` for the new revision.

All 3 replicas must be running the new image when you're done.
