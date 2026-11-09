kubectl --context main apply -f "$FILES/backupschedules-crd.yaml"
kubectl --context main wait crd/backupschedules.ops.example.com --for=condition=Established --timeout=60s
apply main <<'YAML'
apiVersion: ops.example.com/v1
kind: BackupSchedule
metadata: {name: orders-nightly, namespace: orders-ops}
spec:
  schedule: "0 2 * * *"
  retentionDays: 14
  target: orders-db
YAML
kubectl --context main get crd -o name | sed 's#.*/##' | grep '\.ops\.example\.com$' > "$ANSWERS/ops-crds.txt"
node_exec "$MAIN_W1" "grep containerRuntimeEndpoint /var/lib/kubelet/config.yaml" | awk '{print $2}' > "$ANSWERS/cri-endpoint.txt"
node_exec "$MAIN_W1" "ls /etc/cni/net.d" | sort | head -1 > "$ANSWERS/cni-config.txt"
