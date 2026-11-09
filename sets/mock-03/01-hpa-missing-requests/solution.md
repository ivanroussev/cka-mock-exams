```bash
kubectl config use-context main
kubectl -n pricing describe hpa quote-engine
#   → FailedGetResourceMetric: missing request for cpu in container "engine"
kubectl -n pricing set resources deploy quote-engine \
  --requests=cpu=100m,memory=64Mi --limits=cpu=250m,memory=128Mi
kubectl -n pricing edit hpa quote-engine
```
```yaml
spec:
  minReplicas: 2
  maxReplicas: 6
  metrics:
  - type: Resource
    resource:
      name: cpu
      target: {type: Utilization, averageUtilization: 65}
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 120
```
```bash
kubectl -n pricing get hpa quote-engine -w     # after ~1 min: cpu: 0%/65%
```
**Why:** a `Utilization` target is a percentage *of the request*. Without a CPU request on every container the HPA
can't compute it and shows `<unknown>`. Docs: search "HorizontalPodAutoscaler Walkthrough" and "configurable scaling behavior".
