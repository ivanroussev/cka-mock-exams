install_metrics_server main
ns main audit
apply main <<YAML
apiVersion: apps/v1
kind: Deployment
metadata: {name: ledger-writer, namespace: audit}
spec:
  replicas: 1
  selector: {matchLabels: {app: ledger-writer}}
  template:
    metadata: {labels: {app: ledger-writer}}
    spec:
      containers:
      - name: app
        image: $IMG_BUSYBOX
        command:
        - sh
        - -c
        - |
          L=/var/log/app/app.log
          echo "\$(date +%T) INFO  starting ledger-writer v2.3" >> \$L
          echo "\$(date +%T) ERROR E-1042 checksum mismatch in batch 7781" >> \$L
          echo "\$(date +%T) WARN  slow disk, retrying" >> \$L
          echo "\$(date +%T) ERROR E-2210 duplicate transaction tx-55102" >> \$L
          echo "\$(date +%T) ERROR E-3007 ledger lock held by pid 412" >> \$L
          i=0; while true; do i=\$((i+1)); echo "\$(date +%T) INFO  heartbeat \$i" >> \$L; sleep 5; done
        volumeMounts: [{name: logs, mountPath: /var/log/app}]
      volumes: [{name: logs, emptyDir: {}}]
---
apiVersion: v1
kind: Pod
metadata: {name: analytics, namespace: audit}
spec:
  containers:
  - {name: api, image: $IMG_NGINX}
  - {name: transcoder, image: $IMG_POLINUX, command: ["stress", "--cpu", "1"]}
  - {name: indexer, image: $IMG_BUSYBOX, command: ["sh", "-c", "while true; do sleep 1; done"]}
YAML
kubectl --context main -n audit rollout status deploy/ledger-writer --timeout=120s >/dev/null
wait_for 180 bash -c "kubectl --context main top pod analytics -n audit --containers --no-headers | grep -q transcoder"
