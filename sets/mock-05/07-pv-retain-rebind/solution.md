A `Released` PV still carries the `claimRef` of the deleted claim (incl. its UID), so no new claim can bind to it.
Remove the stale `claimRef` (data stays on disk because the policy is `Retain`), then pin the new claim with `volumeName`.

```bash
kubectl get pv pv-archive                       # STATUS Released, CLAIM records/archive-2019
kubectl patch pv pv-archive --type=json -p='[{"op":"remove","path":"/spec/claimRef"}]'
kubectl get pv pv-archive                       # Available

cat <<'YAML' | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata: {name: archive-restore, namespace: records}
spec:
  storageClassName: archive
  volumeName: pv-archive          # bind to exactly this PV
  accessModes: [ReadWriteOnce]
  resources: {requests: {storage: 1Gi}}
---
apiVersion: v1
kind: Pod
metadata: {name: archive-reader, namespace: records}
spec:
  containers:
  - {name: reader, image: busybox:1.37, command: [sleep, infinity], volumeMounts: [{name: data, mountPath: /archive}]}
  volumes: [{name: data, persistentVolumeClaim: {claimName: archive-restore}}]
YAML
kubectl -n records exec archive-reader -- cat /archive/marker.txt
```
**Pitfalls:** deleting and recreating the PV also works for `local`/`hostPath` volumes, but on cloud disks it's how data gets lost —
patching `claimRef` is the safe way. (Alternative: set `claimRef` to the *new* claim's namespace/name, without a `uid`.)
The pod lands on `cka-main-worker` automatically: the PV's `nodeAffinity` steers it there.
