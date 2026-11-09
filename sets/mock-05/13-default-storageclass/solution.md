```bash
kubectl get sc standard -o yaml | grep provisioner          # rancher.io/local-path
kubectl patch sc standard -p '{"metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
```
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-retain
  annotations: {storageclass.kubernetes.io/is-default-class: "true"}
provisioner: rancher.io/local-path
reclaimPolicy: Retain
volumeBindingMode: WaitForFirstConsumer
```
Then the PVC (no `storageClassName` field at all) and the pod mounting it; `kubectl get sc` shows `(default)` only next to `local-retain`,
and `kubectl -n lab-sc get pvc scratch` shows `STORAGECLASS local-retain`, `Bound` once the pod is scheduled.
Docs: *Storage → Storage Classes* and *Change the default StorageClass*.
**Pitfalls:** the default is applied when the PVC is **created** — a PVC created before you switched keeps the old class
(or none) forever. `storageClassName: ""` means "no class", not "default". With two defaults, the newest one wins — so remove the old annotation.
