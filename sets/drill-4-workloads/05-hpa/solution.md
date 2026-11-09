```bash
kubectl config use-context main
kubectl -n autoscale set resources deploy/cruncher --requests=cpu=100m --limits=cpu=250m
kubectl -n autoscale autoscale deploy cruncher --min=2 --max=6 --cpu=60% --dry-run=client -o yaml > hpa.yaml
#   (older kubectl: --cpu-percent=60) — then add the behavior block and apply
kubectl apply -f hpa.yaml
kubectl -n autoscale get hpa cruncher -w          # TARGETS goes from <unknown>/60% to e.g. 0%/60%
```
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata: {name: cruncher, namespace: autoscale}
spec:
  scaleTargetRef: {apiVersion: apps/v1, kind: Deployment, name: cruncher}
  minReplicas: 2
  maxReplicas: 6
  metrics:
  - type: Resource
    resource: {name: cpu, target: {type: Utilization, averageUtilization: 60}}
  behavior:
    scaleDown: {stabilizationWindowSeconds: 120}
```
Docs: *Horizontal Pod Autoscaling → Configurable scaling behavior* and the *HorizontalPodAutoscaler Walkthrough*.

- Utilization is a percentage **of the request**. If the containers have no CPU request, the HPA can't compute it and shows `<unknown>`
  (condition `FailedGetResourceMetric`). That's why step 1 matters.
- `kubectl autoscale` has no flag for `behavior`, so you have to edit the YAML. It goes under `spec.behavior`, not under `metrics`.
- Right after you create it, the HPA scales the Deployment up to `minReplicas` (2) even when there's no load.
