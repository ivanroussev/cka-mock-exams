ns main billing
rev() { # rev <change-cause> <image> <command-json>
  apply main <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: invoice-api
  namespace: billing
  annotations: {kubernetes.io/change-cause: "$1"}
spec:
  replicas: 3
  revisionHistoryLimit: 10
  selector: {matchLabels: {app: invoice-api}}
  template:
    metadata: {labels: {app: invoice-api}}
    spec:
      containers:
      - name: api
        image: $2
        command: $3
YAML
}
rev "v1: stable on nginx 1.27" "$IMG_NGINX" '["nginx", "-g", "daemon off;"]'
kubectl --context main -n billing rollout status deploy/invoice-api --timeout=120s >/dev/null
rev "v2: move to nginx 1.28" "$IMG_NGINX2" '["nginx", "-g", "daemon off;"]'
kubectl --context main -n billing rollout status deploy/invoice-api --timeout=120s >/dev/null
rev "v3: new entrypoint" "$IMG_NGINX2" '["sh", "-c", "echo loading plugins; exit 1"]'
sleep 5
