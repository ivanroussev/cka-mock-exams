ns alt checkout
apply alt <<YAML
apiVersion: apps/v1
kind: Deployment
metadata: {name: cart, namespace: checkout}
spec:
  replicas: 2
  selector: {matchLabels: {app: cart}}
  template:
    metadata: {labels: {app: cart}}
    spec:
      tolerations:
      - {key: node-role.kubernetes.io/control-plane, operator: Exists, effect: NoSchedule}
      containers: [{name: cart, image: $IMG_NGINX}]
YAML
# Break the scheduler: typo in the binary name of the static pod manifest.
kubectl --context alt -n checkout scale deploy cart --replicas=0 >/dev/null
node_exec "$ALT_CP" "sed -i 's/- kube-scheduler$/- kube-schedulerr/' /etc/kubernetes/manifests/kube-scheduler.yaml"
sleep 20
kubectl --context alt -n checkout scale deploy cart --replicas=2 >/dev/null
