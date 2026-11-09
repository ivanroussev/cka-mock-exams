# Each worker advertises 2 units of an extended resource (like a GPU or licence slot).
# (Retried: right after cluster creation the API server sometimes drops requests or RBAC isn't warm yet.)
wait_api main 180
for n in "$MAIN_W1" "$MAIN_W2"; do
  wait_for 180 bash -c "kubectl --context main patch node $n --subresource=status --type=json -p='[{\"op\":\"add\",\"path\":\"/status/capacity/example.com~1batch-slot\",\"value\":\"2\"}]' && [ \"\$(kubectl --context main get node $n -o jsonpath='{.status.allocatable.example\.com/batch-slot}')\" = 2 ]"
done
ns main pipeline
apply main <<YAML
apiVersion: apps/v1
kind: Deployment
metadata: {name: backfill, namespace: pipeline}
spec:
  replicas: 4
  selector: {matchLabels: {app: backfill}}
  template:
    metadata: {labels: {app: backfill}}
    spec:
      terminationGracePeriodSeconds: 0
      containers:
      - name: work
        image: $IMG_BUSYBOX
        command: ["sleep", "infinity"]
        resources:
          requests: {example.com/batch-slot: "1"}
          limits: {example.com/batch-slot: "1"}
YAML
kubectl --context main -n pipeline rollout status deploy/backfill --timeout=120s >/dev/null
cat > "$FILES/ingest.yaml" <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ingest
  namespace: pipeline
spec:
  replicas: 3
  selector:
    matchLabels:
      app: ingest
  template:
    metadata:
      labels:
        app: ingest
    spec:
      terminationGracePeriodSeconds: 0
      containers:
      - name: ingest
        image: $IMG_BUSYBOX
        command: ["sleep", "infinity"]
        resources:
          requests:
            example.com/batch-slot: "1"
          limits:
            example.com/batch-slot: "1"
YAML
