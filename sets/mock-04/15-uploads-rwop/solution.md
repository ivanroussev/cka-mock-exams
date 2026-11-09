```bash
kubectl config use-context main
kubectl -n uploads describe pvc uploads-data
#   ProvisioningFailed … NodePath only supports ReadWriteOnce and ReadWriteOncePod access modes
kubectl -n uploads get pvc uploads-data -o yaml > pvc.yaml
kubectl -n uploads scale deploy uploader --replicas=0  # otherwise the pending pod keeps the PVC from being deleted
kubectl -n uploads delete pvc uploads-data             # accessModes are immutable → recreate
vim pvc.yaml     # accessModes: [ReadWriteOncePod]; drop status, uid, resourceVersion, volume.* annotations
kubectl apply -f pvc.yaml
kubectl -n uploads edit deploy uploader
```
```yaml
spec:
  strategy:
    type: Recreate          # remove the rollingUpdate block, too
```
```bash
kubectl -n uploads scale deploy uploader --replicas=1
kubectl -n uploads get pvc,pods                        # Bound, Running
```
**Why:** `ReadWriteOnce` limits a volume to one *node* (several pods on that node may share it); `ReadWriteOncePod` limits it to one
*pod*. With RWOP a RollingUpdate starts the new pod before the old one stops, so the new pod waits forever for the volume — `Recreate`
stops the old pod first. The local-path provisioner can't do `ReadWriteMany` at all.
