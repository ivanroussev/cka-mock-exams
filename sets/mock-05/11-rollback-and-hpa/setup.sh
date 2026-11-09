install_metrics_server main
ns main web-portal
rev() { # rev <change-cause> <image> <env-json>
  apply main <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: portal
  namespace: web-portal
  annotations: {kubernetes.io/change-cause: "$1"}
spec:
  replicas: 2
  revisionHistoryLimit: 10
  progressDeadlineSeconds: 60
  selector: {matchLabels: {app: portal}}
  template:
    metadata: {labels: {app: portal}}
    spec:
      containers:
      - name: nginx
        image: $2
        env: $3
YAML
}
rev "initial release"           "$IMG_NGINX"  '[]'
kubectl --context main -n web-portal rollout status deploy/portal --timeout=120s >/dev/null
rev "enable gzip"               "$IMG_NGINX2" '[{name: FEATURE_GZIP, value: "on"}]'
kubectl --context main -n web-portal rollout status deploy/portal --timeout=120s >/dev/null
rev "enable response cache"     "$IMG_NGINX2" '[{name: FEATURE_GZIP, value: "on"}, {name: FEATURE_CACHE, value: "on"}]'
kubectl --context main -n web-portal rollout status deploy/portal --timeout=120s >/dev/null
rev "hotfix TCK-4411"           "nginx:1.28-alpine-tck4411" '[{name: FEATURE_GZIP, value: "on"}, {name: FEATURE_CACHE, value: "on"}]'
sleep 5
