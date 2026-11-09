install_metrics_server main
ns main batch
for p in report-a report-b report-c; do
  apply main <<YAML
apiVersion: v1
kind: Pod
metadata: {name: $p, namespace: batch}
spec:
  containers: [{name: work, image: $IMG_BUSYBOX, command: ["sleep", "infinity"]}]
YAML
done
apply main <<YAML
apiVersion: v1
kind: Pod
metadata: {name: report-x7, namespace: batch}
spec:
  containers: [{name: work, image: $IMG_POLINUX, command: ["stress", "--cpu", "1"]}]
YAML
# Wait for metrics to show up for the busy pod.
wait_for 180 bash -c "kubectl --context main top pod -n batch --no-headers | grep -q report-x7"
