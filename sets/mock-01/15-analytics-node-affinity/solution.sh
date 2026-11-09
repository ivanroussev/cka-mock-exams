apply main <<YAML
apiVersion: apps/v1
kind: Deployment
metadata: {name: clickstream-etl, namespace: analytics}
spec:
  replicas: 2
  selector: {matchLabels: {app: clickstream-etl}}
  template:
    metadata: {labels: {app: clickstream-etl}}
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - {key: workload, operator: In, values: [analytics]}
      tolerations:
      - {key: dedicated, operator: Equal, value: analytics, effect: NoSchedule}
      containers:
      - name: busybox
        image: $IMG_BUSYBOX
        command: ["sleep", "86400"]
        resources:
          requests: {cpu: 100m, memory: 64Mi}
          limits: {memory: 128Mi}
YAML
kubectl --context main -n analytics rollout status deploy/clickstream-etl --timeout=120s
