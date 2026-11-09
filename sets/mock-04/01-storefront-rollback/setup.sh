ns main web-shop
D="deploy/storefront"
apply main <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: storefront
  namespace: web-shop
  annotations: {kubernetes.io/change-cause: "initial release"}
spec:
  replicas: 4
  selector: {matchLabels: {app: storefront}}
  template:
    metadata: {labels: {app: storefront}}
    spec:
      containers:
      - name: web
        image: $IMG_NGINX
        ports: [{containerPort: 80}]
YAML
kubectl --context main -n web-shop rollout status $D --timeout=180s >/dev/null
kubectl --context main -n web-shop set image $D web="$IMG_NGINX2" >/dev/null
kubectl --context main -n web-shop annotate $D kubernetes.io/change-cause="upgrade to nginx 1.28" --overwrite >/dev/null
kubectl --context main -n web-shop rollout status $D --timeout=180s >/dev/null
kubectl --context main -n web-shop set image $D web=nginx:1.28-alpine-perf >/dev/null
kubectl --context main -n web-shop annotate $D kubernetes.io/change-cause="switch to perf build" --overwrite >/dev/null
wait_for 60 bash -c "kubectl --context main -n web-shop get rs -l app=storefront -o jsonpath='{.items[*].metadata.annotations.deployment\.kubernetes\.io/revision}' | grep -qw 3"
