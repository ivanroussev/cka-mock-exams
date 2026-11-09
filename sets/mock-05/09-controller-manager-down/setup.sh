ns alt ops
apply alt <<YAML
apiVersion: apps/v1
kind: Deployment
metadata: {name: reports, namespace: ops}
spec:
  replicas: 0
  selector: {matchLabels: {app: reports}}
  template:
    metadata: {labels: {app: reports}}
    spec:
      tolerations:
      - {key: node-role.kubernetes.io/control-plane, operator: Exists, effect: NoSchedule}
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms: [{matchExpressions: [{key: node-role.kubernetes.io/control-plane, operator: Exists}]}]
      containers: [{name: reports, image: $IMG_NGINX}]
YAML
# Break kube-controller-manager: every --*kubeconfig flag points at a file that doesn't exist.
node_exec "$ALT_CP" "sed -i '/^    - --.*kubeconfig=/s#/etc/kubernetes/controller-manager.conf#/etc/kubernetes/controller-manager.kubeconfig#' /etc/kubernetes/manifests/kube-controller-manager.yaml"
sleep 25
kubectl --context alt -n ops scale deploy reports --replicas=2 >/dev/null
