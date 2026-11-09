# Break kube-controller-manager: its --kubeconfig points to a file that doesn't exist.
node_exec "$ALT_CP" "sed -i 's#--kubeconfig=/etc/kubernetes/controller-manager.conf#--kubeconfig=/etc/kubernetes/controller-manager.cnf#' /etc/kubernetes/manifests/kube-controller-manager.yaml"
# Wait until the running controller-manager is gone (the new one crashes).
wait_for 120 bash -c "kubectl --context alt -n kube-system get pod kube-controller-manager-$ALT_CP -o jsonpath='{.spec.containers[0].command}' | grep -q controller-manager.cnf"
sleep 15
ns alt ops
# Pinned to the control plane, so this task doesn't depend on the worker node.
apply alt <<YAML
apiVersion: apps/v1
kind: Deployment
metadata: {name: ledger-sync, namespace: ops}
spec:
  replicas: 2
  selector: {matchLabels: {app: ledger-sync}}
  template:
    metadata: {labels: {app: ledger-sync}}
    spec:
      nodeSelector: {node-role.kubernetes.io/control-plane: ""}
      tolerations:
      - {key: node-role.kubernetes.io/control-plane, operator: Exists, effect: NoSchedule}
      containers:
      - name: sync
        image: $IMG_BUSYBOX
        command: ["sh", "-c", "while true; do echo synced; sleep 30; done"]
YAML
