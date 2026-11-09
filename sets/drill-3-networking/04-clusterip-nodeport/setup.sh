ns main catalog
apply main <<YAML
apiVersion: apps/v1
kind: Deployment
metadata: {name: catalog-web, namespace: catalog}
spec:
  replicas: 2
  selector: {matchLabels: {app: catalog-web}}
  template:
    metadata: {labels: {app: catalog-web}}
    spec:
      containers: [{name: nginx, image: $IMG_NGINX, ports: [{containerPort: 80, name: web}]}]
YAML
kubectl --context main -n catalog rollout status deploy/catalog-web --timeout=120s >/dev/null
