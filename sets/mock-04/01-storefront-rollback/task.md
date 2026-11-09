The latest rollout of Deployment `storefront` in namespace `web-shop` is stuck.

1. Find the **most recent revision** of `storefront` whose rollout worked and write its revision number to `{{ANSWERS}}/storefront-good-revision.txt`.
2. Roll `storefront` back to that revision.
3. Make future rollouts safer: never go below the desired number of ready pods, create at most **1** extra pod at a time, treat a new pod
   as available only after it has been ready for **10 seconds**, and report a rollout as failed after **120 seconds** without progress.
4. Then roll out one more change: set the environment variable `THEME=winter` on the `web` container, and record the change cause
   `enable winter theme` on the Deployment (annotation `kubernetes.io/change-cause`), so it shows in `kubectl rollout history`.

At the end, all 4 replicas must be ready and run image `nginx:1.28-alpine`.
