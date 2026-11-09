ns main billing-app
cat > "$FILES/billing.properties" <<'P'
currency=EUR
invoice.prefix=INV-2026-
tax.rate=0.20
P
apply main <<YAML
apiVersion: apps/v1
kind: Deployment
metadata: {name: billing, namespace: billing-app}
spec:
  replicas: 1
  selector: {matchLabels: {app: billing}}
  template:
    metadata: {labels: {app: billing}}
    spec:
      containers:
      - name: app
        image: $IMG_BUSYBOX
        command: ["sh", "-c", "while true; do sleep 3600; done"]
YAML
kubectl --context main -n billing-app rollout status deploy/billing --timeout=120s >/dev/null
