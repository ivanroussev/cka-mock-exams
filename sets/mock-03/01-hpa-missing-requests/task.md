In namespace `pricing`, the HorizontalPodAutoscaler `quote-engine` has never scaled the Deployment `quote-engine`: its target column shows `<unknown>`.
metrics-server is installed and working.

1. Fix the cause. Every `quote-engine` container must **request** `100m` CPU and `64Mi` memory and be **limited** to `250m` CPU and `128Mi` memory.
2. Change the existing HPA (don't delete it) so that it:
   - keeps between **2** and **6** replicas,
   - targets an average CPU utilisation of **65%**,
   - waits **120 seconds** (stabilisation window) before scaling down.

The HPA must end up reporting a current CPU utilisation.
