ns main records
node_exec "$MAIN_W1" "mkdir -p /srv/records-archive && echo 'archive-2025 index: 1182 records, checksum ok' > /srv/records-archive/index.txt"
apply main <<YAML
apiVersion: v1
kind: PersistentVolume
metadata: {name: records-archive}
spec:
  capacity: {storage: 2Gi}
  accessModes: [ReadWriteOnce]
  persistentVolumeReclaimPolicy: Retain
  storageClassName: archive
  local: {path: /srv/records-archive}
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions: [{key: kubernetes.io/hostname, operator: In, values: [$MAIN_W1]}]
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata: {name: archive-data, namespace: records}
spec:
  storageClassName: archive
  accessModes: [ReadWriteOnce]
  resources: {requests: {storage: 2Gi}}
YAML
wait_for 60 bash -c "[ \"\$(kubectl --context main -n records get pvc archive-data -o jsonpath='{.status.phase}')\" = Bound ]"
kubectl --context main -n records delete pvc archive-data --wait=true >/dev/null
wait_for 60 bash -c "[ \"\$(kubectl --context main get pv records-archive -o jsonpath='{.status.phase}')\" = Released ]"
# Remember the PV's UID so the check can tell it wasn't recreated.
kubectl --context main annotate pv records-archive cka/original-uid="$(kubectl --context main get pv records-archive -o jsonpath='{.metadata.uid}')" --overwrite >/dev/null
