apply main <<YAML
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata: {name: manual-archive}
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
---
apiVersion: v1
kind: PersistentVolume
metadata: {name: archive-pv}
spec:
  capacity: {storage: 512Mi}
  accessModes: [ReadWriteOnce]
  persistentVolumeReclaimPolicy: Retain
  storageClassName: manual-archive
  local: {path: /srv/archive}
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - {key: kubernetes.io/hostname, operator: In, values: [$MAIN_W1]}
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata: {name: archive-claim, namespace: records}
spec:
  storageClassName: manual-archive
  accessModes: [ReadWriteOnce]
  resources: {requests: {storage: 512Mi}}
---
apiVersion: v1
kind: Pod
metadata: {name: archive-reader, namespace: records}
spec:
  containers:
  - name: nginx
    image: $IMG_NGINX
    volumeMounts: [{name: archive, mountPath: /usr/share/nginx/html, readOnly: true}]
  volumes:
  - name: archive
    persistentVolumeClaim: {claimName: archive-claim, readOnly: true}
YAML
kubectl --context main -n records wait pod/archive-reader --for=condition=Ready --timeout=120s
