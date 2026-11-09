install_metrics_server main
ns main product-api
apply main <<YAML
apiVersion: apps/v1
kind: Deployment
metadata: {name: catalog-api, namespace: product-api}
spec:
  replicas: 1
  selector: {matchLabels: {app: catalog-api}}
  template:
    metadata: {labels: {app: catalog-api, tier: backend}}
    spec:
      containers:
      - name: api
        image: $IMG_NGINX
        ports: [{containerPort: 80}]
        resources: {requests: {cpu: 50m, memory: 32Mi}, limits: {memory: 128Mi}}
YAML
kubectl --context main -n product-api rollout status deploy/catalog-api --timeout=120s >/dev/null
