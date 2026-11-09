ns main archive
node_exec "$MAIN_W1" "mkdir -p /srv/archive-pv && echo 'Q3 report: revenue 4.2M' > /srv/archive-pv/report.txt"
apply main <<YAML
apiVersion: v1
kind: PersistentVolume
metadata: {name: archive-pv}
spec:
  capacity: {storage: 1Gi}
  accessModes: [ReadWriteOnce]
  persistentVolumeReclaimPolicy: Retain
  storageClassName: ""
  hostPath: {path: /srv/archive-pv, type: DirectoryOrCreate}
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions: [{key: kubernetes.io/hostname, operator: In, values: [$MAIN_W1]}]
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata: {name: old-claim, namespace: archive}
spec:
  storageClassName: ""
  volumeName: archive-pv
  accessModes: [ReadWriteOnce]
  resources: {requests: {storage: 1Gi}}
YAML
wait_for 60 field_eq main "pvc/old-claim -n archive" '{.status.phase}' Bound
kubectl --context main -n archive delete pvc old-claim --wait=true >/dev/null
wait_for 60 field_eq main "pv/archive-pv" '{.status.phase}' Released
