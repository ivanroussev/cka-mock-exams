source "$TASK_DIR/../lib.sh"
ns main ledger
ns main ledger-ext
echo_app main ledger ledger-db "ledger-db"
kubectl --context main -n ledger expose deploy ledger-db --port 80 >/dev/null
apply main <<YAML
apiVersion: apps/v1
kind: Deployment
metadata: {name: ledger-api, namespace: ledger}
spec:
  replicas: 1
  selector: {matchLabels: {app: ledger-api}}
  template:
    metadata: {labels: {app: ledger-api}}
    spec:
      containers: [{name: api, image: $IMG_NGINX}]
YAML
echo_app main ledger-ext partner "partner"
kubectl --context main -n ledger-ext expose deploy partner --port 80 >/dev/null
kubectl --context main -n ledger rollout status deploy/ledger-db --timeout=120s >/dev/null
kubectl --context main -n ledger-ext rollout status deploy/partner --timeout=120s >/dev/null
