ns main reports-db
apply main <<YAML
apiVersion: v1
kind: PersistentVolumeClaim
metadata: {name: db-data, namespace: reports-db}
spec:
  storageClassName: standart
  accessModes: [ReadWriteMany]
  resources: {requests: {storage: 1Gi}}
---
apiVersion: v1
kind: Pod
metadata: {name: db, namespace: reports-db}
spec:
  containers:
  - name: redis
    image: $IMG_REDIS
    args: ["--dir", "/data", "--appendonly", "yes"]
    volumeMounts: [{name: data, mountPath: /data}]
  volumes:
  - name: data
    persistentVolumeClaim: {claimName: db-data}
YAML
