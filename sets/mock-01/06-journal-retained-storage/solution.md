StorageClass and PVC (docs: "Storage Classes", "Persistent Volumes"):
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: retain-local
provisioner: rancher.io/local-path
reclaimPolicy: Retain
volumeBindingMode: WaitForFirstConsumer
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: journal-data
  namespace: notes
spec:
  storageClassName: retain-local
  accessModes: [ReadWriteOnce]
  resources:
    requests:
      storage: 256Mi
```
```bash
kubectl config use-context main
kubectl apply -f storage.yaml
kubectl -n notes get pvc          # Pending — normal with WaitForFirstConsumer until a pod uses it
kubectl -n notes create deploy journal --image=nginx:1.27-alpine --dry-run=client -o yaml > journal.yaml
# add under the pod spec:
#   volumes: [{name: data, persistentVolumeClaim: {claimName: journal-data}}]
# and under the container:
#   volumeMounts: [{name: data, mountPath: /usr/share/nginx/html}]
kubectl apply -f journal.yaml
kubectl -n notes exec deploy/journal -- sh -c 'echo "journal v1" > /usr/share/nginx/html/index.html'
kubectl -n notes delete pod -l app=journal && kubectl -n notes exec deploy/journal -- cat /usr/share/nginx/html/index.html
kubectl get pv                    # RECLAIM POLICY Retain
```
**Notes:** the PV inherits its reclaim policy from the StorageClass at provisioning time — changing the class later
doesn't change existing PVs (patch the PV's `persistentVolumeReclaimPolicy` for that). With `Retain`, deleting the PVC leaves
the PV `Released` with the data still on disk. A PVC that is `Pending` with WaitForFirstConsumer is not an error.
