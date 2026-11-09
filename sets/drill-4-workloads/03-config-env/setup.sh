ns main portal
printf 'DB_USER=portal_app\nDB_PASSWORD=Xk9-portal-2026\n' > "$FILES/portal-db.env"
apply main <<YAML
apiVersion: v1
kind: ConfigMap
metadata: {name: portal-config, namespace: portal}
data: {THEME: light, LANGUAGE: en}
---
apiVersion: apps/v1
kind: Deployment
metadata: {name: portal, namespace: portal}
spec:
  replicas: 2
  selector: {matchLabels: {app: portal}}
  template:
    metadata: {labels: {app: portal}}
    spec:
      containers:
      - name: portal
        image: $IMG_NGINX
        envFrom: [{configMapRef: {name: portal-config}}]
YAML
kubectl --context main -n portal rollout status deploy/portal --timeout=120s >/dev/null
