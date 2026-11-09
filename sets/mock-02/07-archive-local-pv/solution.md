Docs: "Storage Classes" → *Local*, and "Volumes" → *local* (both have a ready-made example).
```yaml
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
  local:
    path: /srv/archive
  nodeAffinity:                       # mandatory for local volumes
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - {key: kubernetes.io/hostname, operator: In, values: [cka-main-worker]}
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
    image: nginx:1.27-alpine
    volumeMounts:
    - {name: archive, mountPath: /usr/share/nginx/html, readOnly: true}
  volumes:
  - name: archive
    persistentVolumeClaim: {claimName: archive-claim}
```
```bash
kubectl config use-context main
kubectl apply -f archive.yaml
kubectl -n records get pvc,pod -o wide          # Bound to archive-pv, pod on cka-main-worker
kubectl -n records exec archive-reader -- wget -qO- localhost
```
**Notes:** a `local` PV *requires* `nodeAffinity` — the scheduler uses it to place the pod on the right node (that's
why the class uses `WaitForFirstConsumer`). `kubernetes.io/no-provisioner` means nothing creates PVs automatically:
the PVC binds only to a matching pre-created PV (same class, enough capacity, compatible access mode).
With `Retain`, deleting the PVC leaves the PV `Released` and the data untouched.
