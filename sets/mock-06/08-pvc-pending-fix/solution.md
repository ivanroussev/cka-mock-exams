```bash
kubectl -n reports-db describe pod db          # "pod has unbound immediate PersistentVolumeClaims"
kubectl -n reports-db describe pvc db-data     # storageclass.storage.k8s.io "standart" not found
kubectl get sc                                 # standard (rancher.io/local-path)
#   fixing the class name alone isn't enough: local-path only supports ReadWriteOnce
#   → "NodePath only supports ReadWriteOnce and ReadWriteOncePod access modes"

kubectl -n reports-db get pod db -o yaml > db.yaml
kubectl -n reports-db get pvc db-data -o yaml > pvc.yaml
kubectl -n reports-db delete pod db; kubectl -n reports-db delete pvc db-data
vim pvc.yaml     # storageClassName: standard, accessModes: [ReadWriteOnce]; drop status/uid/resourceVersion
vim db.yaml      # add the volume + mount:
#   volumes:      - name: scratch
#                   emptyDir: {medium: Memory, sizeLimit: 64Mi}
#   volumeMounts: - {name: scratch, mountPath: /scratch}
kubectl apply -f pvc.yaml -f db.yaml
kubectl -n reports-db get pvc,pod
```
**Pitfalls:** a PVC's `storageClassName` and `accessModes` are immutable — you must recreate it (and the pod using it, which
holds the `pvc-protection` finalizer). Pod volumes are immutable too. `medium: Memory` is a tmpfs; its usage counts against the
container's memory limit.
