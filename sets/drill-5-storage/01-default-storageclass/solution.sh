apply main <<'YAML'
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-fast
  annotations: {storageclass.kubernetes.io/is-default-class: "true"}
provisioner: rancher.io/local-path
reclaimPolicy: Retain
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
YAML
kubectl --context main annotate sc standard storageclass.kubernetes.io/is-default-class=false --overwrite
apply main <<'YAML'
apiVersion: v1
kind: PersistentVolumeClaim
metadata: {name: scratch, namespace: sc-default}
spec:
  accessModes: [ReadWriteOnce]
  resources: {requests: {storage: 100Mi}}
YAML
