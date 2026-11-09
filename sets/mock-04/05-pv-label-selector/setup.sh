ns main media
apply main <<YAML
apiVersion: v1
kind: PersistentVolume
metadata: {name: media-slow, labels: {tier: slow}}
spec:
  capacity: {storage: 5Gi}
  accessModes: [ReadWriteOnce]
  persistentVolumeReclaimPolicy: Retain
  storageClassName: ""
  hostPath: {path: /srv/media-slow, type: DirectoryOrCreate}
YAML
