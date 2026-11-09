ns main edge
apply main <<YAML
apiVersion: apps/v1
kind: Deployment
metadata: {name: edge-web, namespace: edge}
spec:
  replicas: 2
  selector: {matchLabels: {app: edge-web}}
  template:
    metadata: {labels: {app: edge-web}}
    spec:
      containers: [{name: httpd, image: $IMG_HTTPD, ports: [{containerPort: 80}]}]
YAML
kubectl --context main -n edge rollout status deploy/edge-web --timeout=120s >/dev/null
