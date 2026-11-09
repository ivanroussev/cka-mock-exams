```bash
kubectl config use-context main
kubectl get pv records-archive          # STATUS Released, CLAIM records/archive-data
kubectl get pv records-archive -o jsonpath='{.spec.claimRef}'   # still points at the OLD claim's uid
kubectl patch pv records-archive --type=json -p='[{"op":"remove","path":"/spec/claimRef"}]'
kubectl get pv records-archive          # Available
```
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata: {name: archive-data, namespace: records}
spec:
  storageClassName: archive
  volumeName: records-archive        # optional, pins the binding
  accessModes: [ReadWriteOnce]
  resources: {requests: {storage: 2Gi}}
---
apiVersion: v1
kind: Pod
metadata: {name: archive-reader, namespace: records}
spec:
  containers:
  - name: reader
    image: busybox:1.37
    command: ["sleep", "3600"]
    volumeMounts: [{name: archive, mountPath: /archive, readOnly: true}]
  volumes:
  - name: archive
    persistentVolumeClaim: {claimName: archive-data}
```
**Why:** a `Released` PV keeps `spec.claimRef` (with the deleted claim's UID), so no new claim can bind. Removing the claimRef
makes it `Available` again; the data on disk is untouched because the policy is `Retain`. Deleting the PV would also work for the data
on a `local` volume, but the task forbids it. Docs: "Persistent Volumes → Reclaiming → Retain".
