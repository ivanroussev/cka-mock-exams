Deployment `portal` in namespace `web-portal` is stuck in a failed rollout after the latest change.

1. Roll `portal` back to the revision whose change-cause is **`enable gzip`** — not simply the previous one.
2. Set resources on its container `nginx`: requests `cpu: 100m`, `memory: 64Mi`; limit `cpu: 200m`. The rollout must complete.
3. Create a HorizontalPodAutoscaler `portal` (API `autoscaling/v2`) for the Deployment: 2 to 6 replicas, target **60 % average CPU utilisation**,
   and when scaling down it must only act on recommendations from the last **120 seconds** (stabilisation window).

metrics-server is installed. The HPA must be able to read CPU metrics.
