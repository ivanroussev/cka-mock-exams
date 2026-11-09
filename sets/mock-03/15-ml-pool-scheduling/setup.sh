kubectl --context main label node "$MAIN_W2" pool=ml --overwrite >/dev/null
kubectl --context main taint node "$MAIN_W2" workload=ml:NoSchedule --overwrite >/dev/null
ns main ml
apply main <<YAML
apiVersion: apps/v1
kind: Deployment
metadata: {name: trainer, namespace: ml}
spec:
  replicas: 2
  selector: {matchLabels: {app: trainer}}
  template:
    metadata: {labels: {app: trainer}}
    spec:
      nodeSelector: {pool: ml-gpu}
      tolerations:
      - {key: workload, operator: Equal, value: training, effect: NoSchedule}
      containers:
      - name: trainer
        image: $IMG_BUSYBOX
        command: ["sh", "-c", "echo epoch 1; sleep infinity"]
        resources: {requests: {cpu: 50m, memory: 32Mi}}
YAML
