source "$TASK_DIR/../lib.sh"
ns main shipping
echo_app main shipping label-db "label-db ok" 5432
# A Service exists — but under a different name than the one the app uses.
kubectl --context main -n shipping expose deploy label-db --name labels-db --port 5432 >/dev/null
apply main <<YAML
apiVersion: apps/v1
kind: Deployment
metadata: {name: label-printer, namespace: shipping}
spec:
  replicas: 2
  selector: {matchLabels: {app: label-printer}}
  template:
    metadata: {labels: {app: label-printer}}
    spec:
      initContainers:
      - name: fetch-templates
        image: $IMG_BUSYBOX
        command: ["sh", "-c", "echo templates downloaded"]
      - name: wait-for-db
        image: $IMG_BUSYBOX
        command: ["sh", "-c", "until wget -q -T 2 -O- http://label-db:5432/ >/dev/null 2>&1; do echo 'waiting for label-db:5432 ...'; sleep 3; done; echo 'label-db is up'"]
      containers:
      - name: printer
        image: $IMG_NGINX
YAML
kubectl --context main -n shipping rollout status deploy/label-db --timeout=120s >/dev/null
