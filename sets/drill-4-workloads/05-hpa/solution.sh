kubectl --context main -n autoscale set resources deploy/cruncher --requests=cpu=100m --limits=cpu=250m
kubectl --context main -n autoscale rollout status deploy/cruncher --timeout=120s
apply main <<'YAML'
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata: {name: cruncher, namespace: autoscale}
spec:
  scaleTargetRef: {apiVersion: apps/v1, kind: Deployment, name: cruncher}
  minReplicas: 2
  maxReplicas: 6
  metrics:
  - type: Resource
    resource:
      name: cpu
      target: {type: Utilization, averageUtilization: 60}
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 120
YAML
wait_for 240 bash -c '[ "$(kubectl --context main -n autoscale get hpa cruncher -o jsonpath="{.status.conditions[?(@.type==\"ScalingActive\")].status}")" = True ] &&
  [ -n "$(kubectl --context main -n autoscale get hpa cruncher -o jsonpath="{.status.currentMetrics[0].resource.current.averageUtilization}")" ] &&
  [ "$(kubectl --context main -n autoscale get deploy cruncher -o jsonpath="{.status.readyReplicas}")" -ge 2 ]'
