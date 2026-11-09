kubectl --context main -n ops patch ds log-agent --type=merge -p \
  '{"spec":{"template":{"spec":{"tolerations":[{"key":"node-role.kubernetes.io/control-plane","operator":"Exists","effect":"NoSchedule"}]}}}}'
kubectl --context main -n ops rollout status ds/log-agent --timeout=180s
kubectl --context main taint node $MAIN_W2 workload=ml:NoSchedule
kubectl --context main describe node $MAIN_W2 | grep '^Taints:' > "$ANSWERS/worker2-taints.txt"
apply main <<YAML
apiVersion: apps/v1
kind: Deployment
metadata: {name: trainer, namespace: ops}
spec:
  replicas: 2
  selector: {matchLabels: {app: trainer}}
  template:
    metadata: {labels: {app: trainer}}
    spec:
      nodeSelector: {kubernetes.io/hostname: $MAIN_W2}
      tolerations: [{key: workload, operator: Equal, value: ml, effect: NoSchedule}]
      containers: [{name: trainer, image: $IMG_BUSYBOX, command: ["sleep", "3600"]}]
YAML
kubectl --context main -n ops rollout status deploy/trainer --timeout=120s
kubectl --context main taint node $MAIN_W2 workload=ml:NoSchedule-
