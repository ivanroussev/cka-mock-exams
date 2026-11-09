The latest rollout of Deployment `invoice-api` in namespace `billing` is broken.

1. Roll `invoice-api` back to the revision that ran image `nginx:1.27-alpine`. All 3 replicas must be Ready.
2. Write the revision number the Deployment is on **after** the rollback to `{{ANSWERS}}/invoice-revision.txt`.
3. The team wants to batch some changes. Pause the rollout of `invoice-api`, then add the environment variable `FEATURE_INVOICE_PDF=on`
   to its container. Leave the Deployment paused. The running pods must not be replaced yet.
