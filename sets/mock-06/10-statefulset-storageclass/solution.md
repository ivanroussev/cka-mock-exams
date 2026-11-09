Docs: *StatefulSets* (the example with a headless Service and `volumeClaimTemplates`) and *Storage Classes*.
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata: {name: kv-local}
provisioner: rancher.io/local-path
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
---
apiVersion: v1
kind: Service
metadata: {name: kv, namespace: kv}
spec:
  clusterIP: None                 # headless: DNS returns pod IPs, and gives each pod a name
  selector: {app: kv}
  ports: [{name: redis, port: 6379}]
---
apiVersion: apps/v1
kind: StatefulSet
metadata: {name: kv, namespace: kv}
spec:
  serviceName: kv                 # must name the headless Service
  replicas: 3
  selector: {matchLabels: {app: kv}}
  template:
    metadata: {labels: {app: kv}}
    spec:
      containers:
      - {name: redis, image: redis:7-alpine, args: ["--dir", "/data"], volumeMounts: [{name: data, mountPath: /data}]}
  volumeClaimTemplates:
  - metadata: {name: data}
    spec: {storageClassName: kv-local, accessModes: [ReadWriteOnce], resources: {requests: {storage: 256Mi}}}
```
```bash
kubectl -n kv get sts,pods,pvc        # PVCs are named <template>-<sts>-<ordinal>: data-kv-0, data-kv-1, data-kv-2
kubectl -n kv run t --rm -it --image=busybox:1.37 --restart=Never -- nslookup kv-1.kv.kv.svc.cluster.local
```
**Pitfalls:** without `serviceName` pointing at a *headless* Service, the per-pod DNS names don't exist. PVCs from
`volumeClaimTemplates` are **not** deleted when you scale down or delete the StatefulSet (unless `persistentVolumeClaimRetentionPolicy` says so).
