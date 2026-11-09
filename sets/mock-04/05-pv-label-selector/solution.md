```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: media-fast
  labels: {tier: fast}
spec:
  capacity: {storage: 2Gi}
  accessModes: [ReadWriteOnce]
  persistentVolumeReclaimPolicy: Retain
  storageClassName: ""
  hostPath: {path: /srv/media-fast, type: DirectoryOrCreate}
  nodeAffinity:                       # pins the volume (and so every pod using it) to cka-main-worker
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - {key: kubernetes.io/hostname, operator: In, values: [cka-main-worker]}
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata: {name: media-claim, namespace: media}
spec:
  storageClassName: ""                # ← without this the default class "standard" is filled in and provisions a new volume
  accessModes: [ReadWriteOnce]
  resources: {requests: {storage: 1Gi}}
  selector:
    matchLabels: {tier: fast}
---
apiVersion: v1
kind: Pod
metadata: {name: media-writer, namespace: media}
spec:
  containers:
  - name: writer
    image: busybox:1.37
    command: ["sh", "-c", "echo ready > /media/status && sleep 3600"]
    volumeMounts: [{name: media, mountPath: /media}]
  volumes:
  - name: media
    persistentVolumeClaim: {claimName: media-claim}
```
**Pitfalls:** a PVC with no `storageClassName` gets the default StorageClass and ignores your hand-made PV. `storageClassName: ""` means
"static binding only". A hostPath PV lives on one node only: pin it with `nodeAffinity` (or schedule the pod there with a nodeSelector).
Docs: "Configure a Pod to Use a PersistentVolume for Storage" and "Persistent Volumes → Selector".
