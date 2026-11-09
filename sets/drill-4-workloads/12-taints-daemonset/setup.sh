ns main ops
apply main <<YAML
apiVersion: apps/v1
kind: DaemonSet
metadata: {name: log-agent, namespace: ops}
spec:
  selector: {matchLabels: {app: log-agent}}
  template:
    metadata: {labels: {app: log-agent}}
    spec:
      containers: [{name: agent, image: $IMG_BUSYBOX, command: ["sh", "-c", "while true; do date; sleep 30; done"]}]
YAML
kubectl --context main -n ops rollout status ds/log-agent --timeout=120s >/dev/null
