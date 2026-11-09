```bash
kubectl -n webcfg run portal --image=nginx:1.27-alpine --dry-run=client -o yaml > portal.yaml
# add the volume (docs: search "Projected Volumes")
```
```yaml
spec:
  containers:
  - name: portal
    image: nginx:1.27-alpine
    volumeMounts:
    - {name: bundle, mountPath: /etc/portal, readOnly: true}
  volumes:
  - name: bundle
    projected:
      sources:
      - configMap:
          name: site-config
          items: [{key: site.conf, path: site.conf}]
      - secret:
          name: api-token
          items: [{key: token, path: auth/token}]
```
```bash
kubectl -n webcfg exec portal -- ls -R /etc/portal
```
**Notes:** `items` both selects keys (others are left out) and sets the file path, which may include sub-directories.
Without `items` every key becomes a file. Two separate volumes can't be mounted on the same path — that's what
`projected` is for (it can also add `downwardAPI` and `serviceAccountToken` sources).
