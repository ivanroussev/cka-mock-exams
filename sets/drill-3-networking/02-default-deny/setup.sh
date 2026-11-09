ns main vault
ns main vault-visitors
apply main <<YAML
apiVersion: apps/v1
kind: Deployment
metadata: {name: secrets-api, namespace: vault}
spec:
  replicas: 1
  selector: {matchLabels: {app: secrets-api}}
  template:
    metadata: {labels: {app: secrets-api}}
    spec:
      containers: [{name: nginx, image: $IMG_NGINX, ports: [{containerPort: 80}]}]
---
apiVersion: v1
kind: Service
metadata: {name: secrets-api, namespace: vault}
spec:
  selector: {app: secrets-api}
  ports: [{port: 80, targetPort: 80}]
YAML
kubectl --context main -n vault rollout status deploy/secrets-api --timeout=120s >/dev/null
