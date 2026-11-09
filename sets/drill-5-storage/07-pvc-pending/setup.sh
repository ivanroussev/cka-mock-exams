ns main shop-db
apply main <<YAML
apiVersion: v1
kind: PersistentVolumeClaim
metadata: {name: db-data, namespace: shop-db}
spec:
  storageClassName: standard
  accessModes: [ReadWriteMany]
  resources: {requests: {storage: 500Mi}}
---
apiVersion: apps/v1
kind: Deployment
metadata: {name: db, namespace: shop-db}
spec:
  replicas: 1
  selector: {matchLabels: {app: db}}
  template:
    metadata: {labels: {app: db}}
    spec:
      containers:
      - name: redis
        image: $IMG_REDIS
        volumeMounts: [{name: data, mountPath: /data}]
      volumes: [{name: data, persistentVolumeClaim: {claimName: db-data}}]
YAML
sleep 15
