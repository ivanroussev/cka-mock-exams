Namespace `team-a` needs guard rails. Do the following **in this order**:

1. Create a LimitRange `container-defaults` in `team-a` so that containers without resources get a **default request** of
   `cpu: 100m, memory: 64Mi` and a **default limit** of `cpu: 200m, memory: 128Mi`.
2. Create a ResourceQuota `team-a-quota` in `team-a` that allows at most **3 pods**, **1** CPU of requests in total and **1Gi** of memory limits in total.
3. Create a PriorityClass `team-a-high` with value `100000` (not the global default).
4. Create a Deployment `worker` in `team-a` with image `nginx:1.27-alpine`, **4** replicas, priority class `team-a-high`, and **no** resources in its spec.
5. Not all replicas will start. Write the error message that explains why to `{{ANSWERS}}/quota-error.txt`.
