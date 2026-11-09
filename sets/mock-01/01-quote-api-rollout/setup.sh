ns main quotes
apply main <<YAML
apiVersion: apps/v1
kind: Deployment
metadata: {name: quote-api, namespace: quotes}
spec:
  replicas: 1
  selector: {matchLabels: {app: quote-api}}
  template:
    metadata: {labels: {app: quote-api}}
    spec:
      containers: [{name: web, image: $IMG_NGINX, ports: [{containerPort: 80}]}]
YAML
kubectl --context main -n quotes rollout status deploy/quote-api --timeout=120s >/dev/null
