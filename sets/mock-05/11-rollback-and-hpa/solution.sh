r=$(kubectl --context main -n web-portal rollout history deploy/portal | awk '/enable gzip/{print $1}')
kubectl --context main -n web-portal rollout undo deploy/portal --to-revision="$r" >/dev/null
kubectl --context main -n web-portal rollout status deploy/portal --timeout=120s >/dev/null
kubectl --context main -n web-portal set resources deploy/portal -c nginx --requests=cpu=100m,memory=64Mi --limits=cpu=200m >/dev/null
kubectl --context main -n web-portal rollout status deploy/portal --timeout=120s >/dev/null
apply main <<'YAML'
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata: {name: portal, namespace: web-portal}
spec:
  scaleTargetRef: {apiVersion: apps/v1, kind: Deployment, name: portal}
  minReplicas: 2
  maxReplicas: 6
  metrics:
  - type: Resource
    resource: {name: cpu, target: {type: Utilization, averageUtilization: 60}}
  behavior:
    scaleDown: {stabilizationWindowSeconds: 120}
YAML
wait_for 240 bash -c "[ \"\$(kubectl --context main -n web-portal get hpa portal -o jsonpath='{.status.conditions[?(@.type==\"ScalingActive\")].status}')\" = True ]"
