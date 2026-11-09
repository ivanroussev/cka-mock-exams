install_metrics_server main
for n in data-ingest data-lake data-science; do ns main $n; done
burn() { echo "{name: $1, image: $IMG_POLINUX, command: [stress, --cpu, '1'], resources: {limits: {cpu: $2}}}"; }
idle() { echo "{name: $1, image: $IMG_BUSYBOX, command: [sleep, infinity], resources: {limits: {cpu: 50m}}}"; }
apply main <<YAML
apiVersion: v1
kind: Pod
metadata: {name: kafka-bridge, namespace: data-ingest, labels: {team: data}}
spec: {containers: [$(burn bridge 40m), $(idle exporter)]}
---
apiVersion: v1
kind: Pod
metadata: {name: compactor, namespace: data-lake, labels: {team: data}}
spec: {containers: [$(idle shipper), $(burn compact 150m), $(burn index 60m)]}
---
apiVersion: v1
kind: Pod
metadata: {name: notebook-7f2, namespace: data-science, labels: {team: data}}
spec: {containers: [$(burn kernel 80m)]}
---
apiVersion: v1
kind: Pod
metadata: {name: video-encoder, namespace: data-science, labels: {team: media}}
spec: {containers: [$(burn encoder 250m)]}
YAML
wait_for 240 bash -c "kubectl --context main top pod -n data-lake --containers --no-headers 2>/dev/null | grep -q compact"
