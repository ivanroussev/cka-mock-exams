ns main ingest
kubectl --context main -n ingest create secret generic shipper-creds --from-literal=token=s3cr3t-shipping-token --from-literal=endpoint=logs.example.test >/dev/null
apply main <<YAML
apiVersion: apps/v1
kind: Deployment
metadata: {name: collector, namespace: ingest}
spec:
  replicas: 1
  selector: {matchLabels: {app: collector}}
  template:
    metadata: {labels: {app: collector}}
    spec:
      containers:
      - name: app
        image: $IMG_BUSYBOX
        command: ["sh", "-c", "mkdir -p /var/log/collector; i=0; while true; do i=\$((i+1)); echo \"\$(date -u +%H:%M:%S) collected batch=\$i\" >> /var/log/collector/app.log; sleep 2; done"]
YAML
kubectl --context main -n ingest rollout status deploy/collector --timeout=120s >/dev/null
