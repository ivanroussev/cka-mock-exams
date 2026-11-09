ns main store
apply main <<YAML
apiVersion: apps/v1
kind: Deployment
metadata: {name: shop, namespace: store}
spec:
  replicas: 2
  selector: {matchLabels: {app: shop, tier: web}}
  template:
    metadata: {labels: {app: shop, tier: web}}
    spec:
      containers: [{name: nginx, image: $IMG_NGINX, ports: [{containerPort: 80, name: http}]}]
---
apiVersion: v1
kind: Service
metadata: {name: shop, namespace: store}
spec:
  selector: {app: shop, tier: frontend}
  ports: [{port: 80, targetPort: 8080}]
YAML
kubectl --context main -n store rollout status deploy/shop --timeout=120s >/dev/null
