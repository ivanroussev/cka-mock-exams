ns alt sync
apply alt <<YAML
apiVersion: apps/v1
kind: Deployment
metadata: {name: ledger-sync, namespace: sync}
spec:
  replicas: 0
  selector: {matchLabels: {app: ledger-sync}}
  template:
    metadata: {labels: {app: ledger-sync}}
    spec:
      tolerations:
      - {key: node-role.kubernetes.io/control-plane, operator: Exists, effect: NoSchedule}
      containers: [{name: sync, image: $IMG_BUSYBOX, command: [sleep, infinity]}]
YAML
node_exec "$ALT_CP" "sed -i 's#^      path: /etc/kubernetes/scheduler.conf\$#      path: /etc/kubernetes/scheduler-v2.conf#' /etc/kubernetes/manifests/kube-scheduler.yaml"
# Wait until the healthy scheduler container is gone.
wait_for 120 bash -c "node_exec $ALT_CP 'test -f /etc/kubernetes/scheduler-v2.conf' && ! node_exec $ALT_CP 'crictl ps --name kube-scheduler --state running -q' | grep -q ."
sleep 5
kubectl --context alt -n sync scale deploy ledger-sync --replicas=2 >/dev/null
