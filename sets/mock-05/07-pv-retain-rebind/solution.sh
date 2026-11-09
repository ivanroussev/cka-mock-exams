kubectl --context main patch pv pv-archive --type=json -p='[{"op":"remove","path":"/spec/claimRef"}]' >/dev/null
apply main <<YAML
apiVersion: v1
kind: PersistentVolumeClaim
metadata: {name: archive-restore, namespace: records}
spec:
  storageClassName: archive
  volumeName: pv-archive
  accessModes: [ReadWriteOnce]
  resources: {requests: {storage: 1Gi}}
---
apiVersion: v1
kind: Pod
metadata: {name: archive-reader, namespace: records}
spec:
  containers:
  - name: reader
    image: $IMG_BUSYBOX
    command: ["sleep", "infinity"]
    volumeMounts: [{name: data, mountPath: /archive}]
  volumes:
  - name: data
    persistentVolumeClaim: {claimName: archive-restore}
YAML
wait_for 120 pod_ready main archive-reader records
