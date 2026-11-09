kubectl --context main patch pv archive-pv --type=json -p='[{"op":"remove","path":"/spec/claimRef"}]'
wait_for 30 field_eq main "pv/archive-pv" '{.status.phase}' Available
apply main <<YAML
apiVersion: v1
kind: PersistentVolumeClaim
metadata: {name: archive-claim, namespace: archive}
spec:
  storageClassName: ""
  volumeName: archive-pv
  accessModes: [ReadWriteOnce]
  resources: {requests: {storage: 1Gi}}
---
apiVersion: v1
kind: Pod
metadata: {name: archive-reader, namespace: archive}
spec:
  containers:
  - name: reader
    image: $IMG_BUSYBOX
    command: ["sleep", "3600"]
    volumeMounts: [{name: data, mountPath: /archive}]
  volumes: [{name: data, persistentVolumeClaim: {claimName: archive-claim}}]
YAML
kubectl --context main -n archive wait --for=condition=Ready pod/archive-reader --timeout=90s
