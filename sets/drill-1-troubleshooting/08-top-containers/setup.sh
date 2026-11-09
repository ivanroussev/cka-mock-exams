install_metrics_server main
ns main telemetry
wait_for 60 kubectl --context main -n telemetry get serviceaccount default   # a brand-new namespace gets its SA a moment later; Pods are rejected until then
apply main <<YAML
apiVersion: v1
kind: Pod
metadata: {name: collector, namespace: telemetry}
spec:
  containers:
  - {name: scraper, image: $IMG_BUSYBOX, command: ["sleep", "infinity"]}
  - {name: parser, image: $IMG_POLINUX, command: ["stress", "--cpu", "1"], resources: {limits: {cpu: 300m}}}
  - {name: shipper, image: $IMG_BUSYBOX, command: ["sleep", "infinity"]}
---
apiVersion: v1
kind: Pod
metadata: {name: buffer-1, namespace: telemetry, labels: {tier: buffer}}
spec:
  containers: [{name: buf, image: $IMG_POLINUX, command: ["stress", "--vm", "1", "--vm-bytes", "20M", "--vm-hang", "0"]}]
---
apiVersion: v1
kind: Pod
metadata: {name: buffer-2, namespace: telemetry, labels: {tier: buffer}}
spec:
  containers: [{name: buf, image: $IMG_POLINUX, command: ["stress", "--vm", "1", "--vm-bytes", "64M", "--vm-hang", "0"]}]
---
apiVersion: v1
kind: Pod
metadata: {name: buffer-3, namespace: telemetry, labels: {tier: buffer}}
spec:
  containers: [{name: buf, image: $IMG_BUSYBOX, command: ["sleep", "infinity"]}]
---
apiVersion: v1
kind: Pod
metadata: {name: spool, namespace: telemetry, labels: {tier: spool}}
spec:
  containers: [{name: buf, image: $IMG_POLINUX, command: ["stress", "--vm", "1", "--vm-bytes", "96M", "--vm-hang", "0"]}]
YAML
wait_for 180 bash -c "kubectl --context main top pod -n telemetry collector --containers --no-headers | grep -q parser && kubectl --context main top pod -n telemetry --no-headers | grep -q buffer-2"
