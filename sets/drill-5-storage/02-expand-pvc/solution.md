```bash
kubectl -n reports patch pvc report-data -p '{"spec":{"resources":{"requests":{"storage":"2Gi"}}}}'
#  error: … only dynamically provisioned pvc can be resized and the storageclass that provisions the pvc must support resize
kubectl get pvc -n reports report-data -o jsonpath='{.spec.storageClassName}'   # resizable
kubectl patch sc resizable -p '{"allowVolumeExpansion": true}'                   # this field IS mutable
kubectl -n reports patch pvc report-data -p '{"spec":{"resources":{"requests":{"storage":"2Gi"}}}}'   # or: kubectl edit pvc
kubectl -n reports get pvc report-data
```
With a real CSI driver the PVC shows a `Resizing` / `FileSystemResizePending` condition and then `CAPACITY 2Gi`; most
drivers grow the filesystem online. **Pitfalls:** PVCs can only grow, never shrink; only bound PVCs can be resized;
the PVC's own capacity in `kubectl get pvc` updates only after the resize finished.
