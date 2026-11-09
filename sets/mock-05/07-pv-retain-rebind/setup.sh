node_exec "$MAIN_W1" "mkdir -p /srv/archive && echo 'ledger archive 2019 checksum=7f3a9c' > /srv/archive/marker.txt"
ns main records
apply main <<YAML
apiVersion: v1
kind: PersistentVolume
metadata: {name: pv-archive}
spec:
  capacity: {storage: 1Gi}
  accessModes: [ReadWriteOnce]
  persistentVolumeReclaimPolicy: Retain
  storageClassName: archive
  local: {path: /srv/archive}
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions: [{key: kubernetes.io/hostname, operator: In, values: [$MAIN_W1]}]
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata: {name: archive-2019, namespace: records}
spec:
  storageClassName: archive
  accessModes: [ReadWriteOnce]
  resources: {requests: {storage: 1Gi}}
YAML
wait_for 60 bash -c "[ \"\$(kubectl --context main get pv pv-archive -o jsonpath='{.status.phase}')\" = Bound ]"
kubectl --context main -n records delete pvc archive-2019 --wait=false >/dev/null
wait_for 60 bash -c "[ \"\$(kubectl --context main get pv pv-archive -o jsonpath='{.status.phase}')\" = Released ]"
