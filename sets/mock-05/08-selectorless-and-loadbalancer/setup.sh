ns main legacy; ns main bridge
apply main <<YAML
apiVersion: v1
kind: Pod
metadata: {name: redis-legacy, namespace: legacy}
spec:
  containers: [{name: redis, image: $IMG_REDIS, ports: [{containerPort: 6379}]}]
---
apiVersion: apps/v1
kind: Deployment
metadata: {name: web, namespace: bridge}
spec:
  replicas: 2
  selector: {matchLabels: {app: web}}
  template:
    metadata: {labels: {app: web}}
    spec:
      containers: [{name: nginx, image: $IMG_NGINX, ports: [{containerPort: 80}]}]
YAML
kubectl --context main -n bridge rollout status deploy/web --timeout=120s >/dev/null
wait_for 90 pod_ready main redis-legacy legacy
