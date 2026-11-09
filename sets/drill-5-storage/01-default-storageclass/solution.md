There's no `kubectl create storageclass`; copy the YAML from the docs (search "Storage Classes"):
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-fast
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: rancher.io/local-path
reclaimPolicy: Retain
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
```
```bash
kubectl apply -f sc.yaml
kubectl annotate sc standard storageclass.kubernetes.io/is-default-class=false --overwrite
kubectl get sc                          # exactly one "(default)"
# PVC: no storageClassName line at all → the default class is filled in at creation time
kubectl -n sc-default get pvc scratch -o jsonpath='{.spec.storageClassName}'   # local-fast
```
**Pitfalls:** order matters — a PVC created *before* you switch the default gets `standard` and `storageClassName` can't be
changed afterwards (delete and recreate it). `storageClassName: ""` is not the same as leaving it out: `""` means
"no class, bind only to a PV without class". `provisioner`, `parameters`, `reclaimPolicy` and `volumeBindingMode` are
immutable — to change them, delete and recreate the class.
