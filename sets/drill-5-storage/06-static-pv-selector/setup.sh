ns main teams
for c in red blue green; do
  apply main <<YAML
apiVersion: v1
kind: PersistentVolume
metadata: {name: pv-$c, labels: {team: $c}}
spec:
  capacity: {storage: 1Gi}
  accessModes: [ReadWriteOnce]
  persistentVolumeReclaimPolicy: Retain
  storageClassName: manual
  hostPath: {path: /srv/teams/$c, type: DirectoryOrCreate}
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions: [{key: kubernetes.io/hostname, operator: In, values: [$MAIN_W1]}]
YAML
done
