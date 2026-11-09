apply main <<YAML
apiVersion: v1
kind: PersistentVolumeClaim
metadata: {name: blue-claim, namespace: teams}
spec:
  storageClassName: manual
  selector: {matchLabels: {team: blue}}
  accessModes: [ReadWriteOnce]
  resources: {requests: {storage: 1Gi}}
---
apiVersion: v1
kind: Pod
metadata: {name: blue-app, namespace: teams}
spec:
  containers:
  - name: app
    image: $IMG_BUSYBOX
    command: ["sh", "-c", "echo hello > /work/hello.txt; sleep 3600"]
    volumeMounts: [{name: data, mountPath: /work, subPath: blue-app}]
  volumes: [{name: data, persistentVolumeClaim: {claimName: blue-claim}}]
YAML
kubectl --context main -n teams wait --for=condition=Ready pod/blue-app --timeout=90s
sleep 2
