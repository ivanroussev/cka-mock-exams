```bash
kubectl -n scratch run ram-share --image=busybox:1.37 --dry-run=client -o yaml --command -- sh -c 'echo ready > /cache/status; sleep 3600' > p.yaml
# edit: name the container writer, add the reader container and the volume (docs: search "emptyDir")
```
```yaml
spec:
  volumes:
  - name: cache
    emptyDir:
      medium: Memory
      sizeLimit: 64Mi
  containers:
  - name: writer
    image: busybox:1.37
    command: ["sh", "-c", "echo ready > /cache/status; sleep 3600"]
    volumeMounts: [{name: cache, mountPath: /cache}]
  - name: reader
    image: busybox:1.37
    command: ["sleep", "3600"]
    volumeMounts: [{name: cache, mountPath: /data, readOnly: true}]
```
```bash
kubectl -n scratch exec ram-share -c reader -- cat /data/status
kubectl -n scratch exec ram-share -c reader -- grep /data /proc/mounts    # tmpfs … ro
```
**Notes:** `medium: Memory` uses RAM and the data counts against the containers' **memory** limit. Without `sizeLimit`
a tmpfs emptyDir can grow up to the pod's memory limit (or node RAM). Going over `sizeLimit` gets the pod evicted.
An emptyDir lives exactly as long as the pod — container restarts keep it, pod deletion wipes it.
