ns main ops
kubectl --context main label node "$MAIN_W2" disk=ssd --overwrite >/dev/null
kubectl --context main cordon "$MAIN_W2" >/dev/null
kubectl --context main taint node "$MAIN_W2" maintenance=planned:NoSchedule --overwrite >/dev/null
apply main <<YAML
apiVersion: apps/v1
kind: Deployment
metadata: {name: reports, namespace: ops}
spec:
  replicas: 2
  selector: {matchLabels: {app: reports}}
  template:
    metadata: {labels: {app: reports}}
    spec:
      nodeSelector: {disk: ssd}
      containers: [{name: web, image: $IMG_NGINX}]
YAML
