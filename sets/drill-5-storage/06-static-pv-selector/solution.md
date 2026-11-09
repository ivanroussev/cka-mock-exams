```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata: {name: blue-claim, namespace: teams}
spec:
  storageClassName: manual
  selector:
    matchLabels: {team: blue}
  accessModes: [ReadWriteOnce]
  resources: {requests: {storage: 1Gi}}
---
apiVersion: v1
kind: Pod
metadata: {name: blue-app, namespace: teams}
spec:
  containers:
  - name: app
    image: busybox:1.37
    command: ["sh", "-c", "echo hello > /work/hello.txt; sleep 3600"]
    volumeMounts:
    - {name: data, mountPath: /work, subPath: blue-app}
  volumes:
  - name: data
    persistentVolumeClaim: {claimName: blue-claim}
```
```bash
kubectl get pv -L team                    # pv-blue → Bound teams/blue-claim
ssh cka-main-worker ls -R /srv/teams/blue # blue-app/hello.txt
```
**Binding rules:** a claim binds to a PV only if class, access modes and size (PV ≥ request) match, plus the `selector`
if one is given. Pinning with `spec.volumeName` is the other way. `subPath` mounts a sub-directory of the volume
(kubelet creates it); handy to share one volume between apps — but subPath mounts don't receive ConfigMap/Secret updates.
