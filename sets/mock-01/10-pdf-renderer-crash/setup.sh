ns main invoicing
kubectl --context main -n invoicing create configmap pdf-renderer-config --from-literal=queue.name=invoices-high --from-literal=dpi=300 >/dev/null
apply main <<YAML
apiVersion: apps/v1
kind: Deployment
metadata: {name: pdf-renderer, namespace: invoicing}
spec:
  replicas: 2
  selector: {matchLabels: {app: pdf-renderer}}
  template:
    metadata: {labels: {app: pdf-renderer}}
    spec:
      containers:
      - name: renderer
        image: $IMG_BUSYBOX
        env:
        - {name: RENDER_DPI, valueFrom: {configMapKeyRef: {name: pdf-renderer-config, key: dpi}}}
        command:
        - sh
        - -c
        - |
          echo "pdf-renderer 2.4.1 starting (dpi=\$RENDER_DPI)"
          echo "loading fonts... ok"
          if [ -z "\$RENDER_QUEUE" ]; then
            echo "FATAL config: environment variable RENDER_QUEUE is not set, cannot subscribe to a job queue"
            exit 3
          fi
          echo "subscribed to queue=\$RENDER_QUEUE"
          while true; do sleep 30; echo "idle queue=\$RENDER_QUEUE"; done
YAML
wait_for 120 bash -c "[ \$(kubectl --context main -n invoicing get pods -l app=pdf-renderer -o jsonpath='{.items[0].status.containerStatuses[0].restartCount}') -ge 1 ]"
