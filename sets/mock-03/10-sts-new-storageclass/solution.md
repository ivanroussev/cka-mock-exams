```bash
kubectl config use-context main
kubectl get sc standard -o yaml          # copy as a starting point; drop the is-default-class annotation!
```
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-retain
provisioner: rancher.io/local-path
reclaimPolicy: Retain
volumeBindingMode: WaitForFirstConsumer
```
```bash
kubectl -n consensus get sts quorum -o yaml > quorum.yaml
# volumeClaimTemplates are immutable → recreate the StatefulSet
kubectl -n consensus delete sts quorum
kubectl -n consensus delete pvc data-quorum-0 data-quorum-1 data-quorum-2   # StatefulSets never delete their PVCs by default
vim quorum.yaml        # storageClassName: local-retain; remove status, uid, resourceVersion, creationTimestamp
kubectl apply -f quorum.yaml
kubectl -n consensus get pvc                          # data-quorum-0..2  Bound  local-retain
```
**Pitfalls:** editing `volumeClaimTemplates` is rejected ("updates to statefulset spec for fields other than … are forbidden").
If you forget to delete the old PVCs, the new pods simply re-attach to them — same names, old class. Copying `standard` without
removing its `storageclass.kubernetes.io/is-default-class: "true"` annotation leaves the cluster with two defaults.
