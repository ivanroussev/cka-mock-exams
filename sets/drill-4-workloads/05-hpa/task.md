metrics-server is installed. Deployment `cruncher` in namespace `autoscale` should scale on CPU load.

1. Give the `cruncher` container a CPU request of `100m` and a CPU limit of `250m`.
2. Create a HorizontalPodAutoscaler named `cruncher` (API `autoscaling/v2`) for the Deployment that:
   - keeps between **2** and **6** replicas,
   - targets an average CPU **utilization** of **60%**,
   - waits **120 seconds** (stabilization window) before scaling down.
3. Make sure the HPA can read the current CPU utilization (the TARGETS column in `kubectl get hpa` must not show `<unknown>`).
