kubectl --context main -n reports-db delete pod db --wait=true --grace-period=1 >/dev/null 2>&1
kubectl --context main -n reports-db delete pvc db-data --wait=true >/dev/null 2>&1
apply main <<YAML
apiVersion: v1
kind: PersistentVolumeClaim
metadata: {name: db-data, namespace: reports-db}
spec:
  storageClassName: standard
  accessModes: [ReadWriteOnce]
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
    volumeMounts:
    - {name: data, mountPath: /data}
    - {name: scratch, mountPath: /scratch}
  volumes:
  - name: data
    persistentVolumeClaim: {claimName: db-data}
  - name: scratch
    emptyDir: {medium: Memory, sizeLimit: 64Mi}
YAML
wait_for 150 pod_ready main db reports-db
wait_for 30 bash -c "kubectl --context main -n reports-db exec db -c redis -- ls /data/appendonlydir"
