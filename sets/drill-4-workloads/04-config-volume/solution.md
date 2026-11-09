```bash
kubectl config use-context main
kubectl -n docs create configmap docs-site --from-file=index.html={{FILES}}/index.html --from-literal=release=3 --dry-run=client -o yaml > cm.yaml
#   add a top-level line  immutable: true   then:
kubectl apply -f cm.yaml
kubectl -n docs create secret generic docs-auth --from-literal=token=tk-7f3a91
kubectl -n docs run docs --image=nginx:1.27-alpine --dry-run=client -o yaml > docs.yaml   # then add the volumes
```
```yaml
    volumeMounts:
    - {name: site, mountPath: /usr/share/nginx/html}
    - {name: auth, mountPath: /etc/docs-auth, readOnly: true}
  volumes:
  - name: site
    configMap:
      name: docs-site
      items: [{key: index.html, path: index.html}]   # only this key is projected
  - name: auth
    secret: {secretName: docs-auth, defaultMode: 0400}
```
Docs: *ConfigMaps → Using ConfigMaps as files from a Pod* and *Secrets → Projection of Secret keys to specific paths*.

- Without `items`, every key becomes a file, so `release` would show up in the web root.
- `defaultMode` is octal in YAML (`0400`). In JSON you'd have to write the decimal `256`. Secret files are symlinks, so `stat -L` shows the real mode.
- An immutable ConfigMap can't be edited. To change it you delete and recreate it (and restart the pods that use it).
  You can't switch `immutable` back to false either.
- Mounting with `subPath` would also work, but then the file never picks up ConfigMap changes.
