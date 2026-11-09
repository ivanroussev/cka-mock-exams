```bash
kubectl -n shop-db describe pod -l app=db       # … unbound immediate PersistentVolumeClaims / waiting for volume
kubectl -n shop-db describe pvc db-data         # Events: ProvisioningFailed … the access mode ReadWriteMany is not supported (local-path is node-local)
kubectl -n shop-db get pvc db-data -o yaml > pvc.yaml   # edit: accessModes [ReadWriteOnce]; strip status/uid/annotations
kubectl -n shop-db scale deploy db --replicas=0  # the pod holds the claim (pvc-protection finalizer)
kubectl -n shop-db delete pvc db-data
kubectl apply -f pvc.yaml
kubectl -n shop-db scale deploy db --replicas=1
```
**Diagnosis path:** pod Pending → `describe pod` points at the PVC → `describe pvc` shows the provisioner's event.
A PVC's spec (except the requested size) is immutable, so a wrong access mode or class means delete and recreate.
**Access modes:** RWO (one node), ROX (many nodes read-only), RWX (many nodes read-write — needs NFS/CephFS-like storage),
RWOP (exactly one pod). Node-local storage such as local-path or hostPath can't do RWX.
