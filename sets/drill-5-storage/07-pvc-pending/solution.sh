kubectl --context main -n shop-db scale deploy db --replicas=0
kubectl --context main -n shop-db wait --for=delete pod -l app=db --timeout=60s
kubectl --context main -n shop-db delete pvc db-data --timeout=60s
apply main <<YAML
apiVersion: v1
kind: PersistentVolumeClaim
metadata: {name: db-data, namespace: shop-db}
spec:
  storageClassName: standard
  accessModes: [ReadWriteOnce]
  resources: {requests: {storage: 500Mi}}
YAML
kubectl --context main -n shop-db scale deploy db --replicas=1
kubectl --context main -n shop-db rollout status deploy/db --timeout=120s
