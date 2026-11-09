install_metrics_server main
ns main autoscale
apply main <<YAML
apiVersion: apps/v1
kind: Deployment
metadata: {name: cruncher, namespace: autoscale}
spec:
  replicas: 1
  selector: {matchLabels: {app: cruncher}}
  template:
    metadata: {labels: {app: cruncher}}
    spec:
      containers: [{name: cruncher, image: $IMG_NGINX}]
YAML
kubectl --context main -n autoscale rollout status deploy/cruncher --timeout=120s >/dev/null
