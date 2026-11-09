install_metrics_server main
ns main analytics
stress() { echo "{name: $1, image: $IMG_POLINUX, command: [stress, --vm, '1', --vm-bytes, $2, --vm-hang, '0']}"; }
idle() { echo "{name: $1, image: $IMG_BUSYBOX, command: [sleep, infinity]}"; }
apply main <<YAML
apiVersion: v1
kind: Pod
metadata: {name: etl-ingest, namespace: analytics, labels: {stage: ingest}}
spec:
  containers: [$(stress reader 60M), $(idle writer)]
---
apiVersion: v1
kind: Pod
metadata: {name: etl-transform, namespace: analytics, labels: {stage: transform}}
spec:
  containers: [$(idle mapper), $(stress reducer 170M), $(stress sorter 90M)]
---
apiVersion: v1
kind: Pod
metadata: {name: etl-export, namespace: analytics, labels: {stage: export}}
spec:
  containers: [$(stress uploader 120M)]
YAML
wait_for 240 bash -c "kubectl --context main top pod -n analytics --containers --no-headers 2>/dev/null | grep -q reducer"
