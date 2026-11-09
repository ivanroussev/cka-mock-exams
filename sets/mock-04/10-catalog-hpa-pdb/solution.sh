# Retry API calls: on a busy laptop the API server sometimes times out the TLS handshake.
retry() { wait_for 180 "$@"; }
apply() { local f; f=$(mktemp); cat > "$f"; retry kubectl --context "$1" apply -f "$f"; local r=$?; rm -f "$f"; return $r; }
retry kubectl --context main -n product-api patch deploy catalog-api --type=json -p='[
 {"op":"add","path":"/spec/template/spec/containers/0/livenessProbe","value":{"httpGet":{"path":"/","port":80},"initialDelaySeconds":10,"periodSeconds":15}},
 {"op":"add","path":"/spec/template/spec/containers/0/readinessProbe","value":{"httpGet":{"path":"/","port":80},"periodSeconds":5}}]'
apply main <<'YAML'
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata: {name: catalog-api, namespace: product-api}
spec:
  scaleTargetRef: {apiVersion: apps/v1, kind: Deployment, name: catalog-api}
  minReplicas: 3
  maxReplicas: 10
  metrics:
  - type: Resource
    resource: {name: cpu, target: {type: Utilization, averageUtilization: 70}}
  - type: Resource
    resource: {name: memory, target: {type: AverageValue, averageValue: 200Mi}}
  behavior:
    scaleUp:
      policies: [{type: Pods, value: 2, periodSeconds: 60}]
---
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata: {name: catalog-api, namespace: product-api}
spec:
  minAvailable: 2
  selector: {matchLabels: {app: catalog-api}}
YAML
wait_for 240 bash -c "[ \"\$(kubectl --context main -n product-api get hpa catalog-api -o jsonpath='{.status.conditions[?(@.type==\"ScalingActive\")].status}')\" = True ] && [ \"\$(kubectl --context main -n product-api get deploy catalog-api -o jsonpath='{.status.readyReplicas}')\" -ge 3 ]"
kubectl --context main -n product-api rollout status deploy/catalog-api --timeout=180s
wait_for 60 bash -c "[ \"\$(kubectl --context main -n product-api get pdb catalog-api -o jsonpath='{.status.expectedPods}')\" = \"\$(kubectl --context main -n product-api get deploy catalog-api -o jsonpath='{.status.replicas}')\" ]"
