Deployment `catalog-api` in namespace `product-api` must become self-healing and elastic. metrics-server is installed.

1. Add a **liveness** probe and a **readiness** probe to the `api` container: both HTTP GET on path `/` port `80`; the liveness probe
   starts after `10` seconds and runs every `15` seconds, the readiness probe runs every `5` seconds.
2. Create a HorizontalPodAutoscaler `catalog-api` (`autoscaling/v2`) for it: `3` to `10` replicas, scale on **both** average CPU
   utilisation `70%` and average memory **usage** of `200Mi` per pod. When scaling up, add at most **2 pods per 60 seconds**.
3. Create a PodDisruptionBudget `catalog-api` that keeps at least **2** `catalog-api` pods available during voluntary disruptions.
