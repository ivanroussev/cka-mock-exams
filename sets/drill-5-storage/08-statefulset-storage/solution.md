```bash
kubectl -n kvstore create service clusterip kv --clusterip=None --tcp=6379:6379 --dry-run=client -o yaml > svc.yaml
#  then set the selector to app: kv (create service sets app: kv already — check it)
```
StatefulSet YAML from the docs (search "StatefulSets", the `web` example), adapted:
```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata: {name: kv, namespace: kvstore}
spec:
  serviceName: kv
  replicas: 2
  selector: {matchLabels: {app: kv}}
  template:
    metadata: {labels: {app: kv}}
    spec:
      containers:
      - name: redis
        image: redis:7-alpine
        volumeMounts: [{name: data, mountPath: /data}]
  volumeClaimTemplates:
  - metadata: {name: data}
    spec:
      storageClassName: standard
      accessModes: [ReadWriteOnce]
      resources: {requests: {storage: 256Mi}}
```
```bash
kubectl -n kvstore get pvc        # data-kv-0, data-kv-1 → <template>-<sts>-<ordinal>
```
**Notes:** the claims outlive the StatefulSet — deleting or scaling it down keeps them (unless
`persistentVolumeClaimRetentionPolicy` says otherwise), and `kv-0` always gets `data-kv-0` back.
Pods start one after the other (`OrderedReady`), so a stuck `kv-0` blocks `kv-1`.
