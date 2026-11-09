```bash
kubectl config use-context main
kubectl -n portal create secret generic portal-db --from-env-file={{FILES}}/portal-db.env
kubectl -n portal edit cm portal-config                          # THEME: dark
kubectl -n portal set env deploy/portal --from=secret/portal-db --keys=DB_PASSWORD --prefix=PORTAL_
# set env changed the pod template, so this already rolls out new pods. If you'd edited only the ConfigMap:
kubectl -n portal rollout restart deploy/portal
kubectl -n portal rollout status deploy/portal
kubectl -n portal exec deploy/portal -- env | grep -E 'THEME|PORTAL_DB|DB_USER'
```
The YAML that `set env` writes (docs: *Secrets → Using Secrets as environment variables*):
```yaml
env:
- name: PORTAL_DB_PASSWORD
  valueFrom:
    secretKeyRef: {name: portal-db, key: DB_PASSWORD}
```
- `--from-env-file` makes one key per `KEY=value` line. `--from-file` would make **one** key (`portal-db.env`) holding the whole file.
- Environment variables are read only when the container starts. Changing a ConfigMap never updates the env of running pods, so you need
  new pods (`rollout restart`). Files from a mounted ConfigMap do update, after a minute or so, unless they're mounted with `subPath`.
- `envFrom: secretRef` would expose `DB_USER` as well. Use `valueFrom.secretKeyRef` for a single key.
