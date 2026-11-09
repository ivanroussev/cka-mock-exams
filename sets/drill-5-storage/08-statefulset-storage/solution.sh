apply main <<YAML
apiVersion: v1
kind: Service
metadata: {name: kv, namespace: kvstore}
spec:
  clusterIP: None
  selector: {app: kv}
  ports: [{port: 6379}]
---
apiVersion: apps/v1
kind: StatefulSet
metadata: {name: kv, namespace: kvstore}
spec:
  serviceName: kv
  replicas: 2
  selector: {matchLabels: {app: kv}}
  template:
    metadata: {labels: {app: kv}}
    spec:
      containers:
      - name: redis
        image: $IMG_REDIS
        ports: [{containerPort: 6379}]
        volumeMounts: [{name: data, mountPath: /data}]
  volumeClaimTemplates:
  - metadata: {name: data}
    spec:
      storageClassName: standard
      accessModes: [ReadWriteOnce]
      resources: {requests: {storage: 256Mi}}
YAML
kubectl --context main -n kvstore rollout status sts/kv --timeout=180s
