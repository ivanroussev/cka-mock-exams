ns main alerts
apply main <<YAML
apiVersion: v1
kind: Secret
metadata: {name: smtp-credentials, namespace: alerts}
stringData: {username: notifier@shop.example, password: Tr0ub4dor-77}
---
apiVersion: v1
kind: ConfigMap
metadata: {name: notifier-config, namespace: alerts}
data: {SMTP_HOST: smtp.relay.internal, SMTP_PORT: "587", ALERT_CHANNEL: ops-pager}
---
apiVersion: apps/v1
kind: Deployment
metadata: {name: notifier, namespace: alerts}
spec:
  replicas: 1
  selector: {matchLabels: {app: notifier}}
  template:
    metadata: {labels: {app: notifier}}
    spec:
      containers:
      - name: notifier
        image: $IMG_BUSYBOX
        command:
        - sh
        - -c
        - |
          echo "notifier 2.3.1 starting"
          [ -n "\$SMTP_PASSWORD" ] || { echo "FATAL: SMTP_PASSWORD is empty, refusing to start"; sleep 2; exit 1; }
          [ -n "\$SMTP_HOST" ] && [ -n "\$SMTP_PORT" ] || { echo "FATAL: SMTP_HOST/SMTP_PORT not configured"; sleep 2; exit 1; }
          echo "connected to \$SMTP_HOST:\$SMTP_PORT, alerts go to \${ALERT_CHANNEL:-nowhere}"
          while true; do sleep 30; echo "queue empty"; done
        env:
        - name: SMTP_USER
          valueFrom: {secretKeyRef: {name: smtp-credentials, key: username}}
        - name: SMTP_PASSWORD
          valueFrom: {secretKeyRef: {name: smtp-credentials, key: smtp-password, optional: true}}
YAML
wait_for 120 bash -c "[ \"\$(kubectl --context main -n alerts get pods -l app=notifier -o jsonpath='{.items[0].status.containerStatuses[0].restartCount}')\" -ge 1 ]"
