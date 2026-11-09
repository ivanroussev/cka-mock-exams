ns alt billing-ops
apply alt <<YAML
apiVersion: apps/v1
kind: Deployment
metadata: {name: invoicer, namespace: billing-ops}
spec:
  replicas: 0
  selector: {matchLabels: {app: invoicer}}
  template:
    metadata: {labels: {app: invoicer}}
    spec:
      nodeSelector: {kubernetes.io/hostname: $ALT_CP}
      tolerations:
      - {key: node-role.kubernetes.io/control-plane, operator: Exists, effect: NoSchedule}
      containers: [{name: invoicer, image: $IMG_NGINX}]
YAML
node_exec "$ALT_CP" "sed -i 's#--kubeconfig=/etc/kubernetes/controller-manager.conf#--kubeconfig=/etc/kubernetes/controller-manager.kubeconfig#' /etc/kubernetes/manifests/kube-controller-manager.yaml"
# Wait until the old controller-manager container is gone before scaling up.
wait_for 90 bash -c "! node_exec $ALT_CP 'crictl ps --name kube-controller-manager -q' | grep -q ."
sleep 5
kubectl --context alt -n billing-ops scale deploy invoicer --replicas=2 >/dev/null
