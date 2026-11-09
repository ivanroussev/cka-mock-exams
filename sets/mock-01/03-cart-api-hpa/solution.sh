apply main <<'YAML'
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata: {name: cart-api, namespace: checkout}
spec:
  scaleTargetRef: {apiVersion: apps/v1, kind: Deployment, name: cart-api}
  minReplicas: 2
  maxReplicas: 8
  metrics:
  - type: Resource
    resource: {name: cpu, target: {type: Utilization, averageUtilization: 65}}
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 180
      policies:
      - {type: Pods, value: 1, periodSeconds: 60}
YAML
