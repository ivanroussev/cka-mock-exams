install_metrics_server main
ns main pricing
apply main <<YAML
apiVersion: apps/v1
kind: Deployment
metadata: {name: quote-engine, namespace: pricing, labels: {app: quote-engine}}
spec:
  replicas: 2
  selector: {matchLabels: {app: quote-engine}}
  template:
    metadata: {labels: {app: quote-engine}}
    spec:
      containers:
      - name: engine
        image: $IMG_NGINX
        ports: [{containerPort: 80}]
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata: {name: quote-engine, namespace: pricing}
spec:
  scaleTargetRef: {apiVersion: apps/v1, kind: Deployment, name: quote-engine}
  minReplicas: 1
  maxReplicas: 4
  metrics:
  - type: Resource
    resource: {name: cpu, target: {type: Utilization, averageUtilization: 80}}
YAML
kubectl --context main -n pricing rollout status deploy/quote-engine --timeout=120s >/dev/null
# Record the HPA's UID so the check can tell whether it was recreated.
kubectl --context main -n pricing annotate hpa quote-engine cka/original-uid="$(kubectl --context main -n pricing get hpa quote-engine -o jsonpath='{.metadata.uid}')" --overwrite >/dev/null
