ns main rollout
apply main <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: storefront
  namespace: rollout
  annotations: {kubernetes.io/change-cause: "initial release"}
spec:
  replicas: 4
  selector: {matchLabels: {app: storefront}}
  template:
    metadata: {labels: {app: storefront}}
    spec:
      containers: [{name: nginx, image: $IMG_NGINX, ports: [{containerPort: 80}]}]
YAML
kubectl --context main -n rollout rollout status deploy/storefront --timeout=120s >/dev/null
