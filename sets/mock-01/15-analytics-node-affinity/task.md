Node `cka-main-worker2` is reserved for analytics: it carries the label `workload=analytics` and the taint `dedicated=analytics:NoSchedule`.

Create a Deployment `clickstream-etl` in namespace `analytics` with **2** replicas, image `busybox:1.37`, command `sleep 86400`, that:

- may run **only** on nodes labelled `workload=analytics` — use a **required node affinity** rule (not `nodeSelector`),
- tolerates the `dedicated=analytics:NoSchedule` taint,
- requests `100m` CPU and `64Mi` memory, and is limited to `128Mi` memory.

Both replicas must be running on `cka-main-worker2`.
