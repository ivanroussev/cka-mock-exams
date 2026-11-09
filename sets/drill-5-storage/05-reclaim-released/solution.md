A **Released** PV still has a `claimRef` pointing at the deleted claim (by UID), so no new claim can bind to it.
Removing the `claimRef` makes it **Available** again; the data on disk is untouched (that's what `Retain` is for).
```bash
kubectl get pv archive-pv                     # STATUS Released, CLAIM archive/old-claim
kubectl patch pv archive-pv --type=json -p='[{"op":"remove","path":"/spec/claimRef"}]'
#   (or: kubectl edit pv archive-pv → delete the claimRef block)
kubectl get pv archive-pv                     # Available
```
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata: {name: archive-claim, namespace: archive}
spec:
  storageClassName: ""          # the PV has no class; leaving this out would assign the default class → no match
  volumeName: archive-pv        # optional here, but pins it to this PV
  accessModes: [ReadWriteOnce]
  resources: {requests: {storage: 1Gi}}
```
Then `kubectl -n archive run archive-reader --image=busybox:1.37 --dry-run=client -o yaml --command -- sleep 3600`,
add the `persistentVolumeClaim` volume and mount, apply, and `kubectl exec … -- cat /archive/report.txt`.

**Reclaim policies:** `Delete` removes the PV *and* the backing storage when the claim goes; `Retain` keeps both and
leaves the PV Released for an admin to clean up or reuse. Change it on a live PV with
`kubectl patch pv <pv> -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'`.
