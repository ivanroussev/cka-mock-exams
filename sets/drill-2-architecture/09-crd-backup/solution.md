Docs: search **"CustomResourceDefinition"** → *Extend the Kubernetes API with CustomResourceDefinitions* (copy the CronTab example and adapt it).
```yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: backups.ops.cka.io          # must be <plural>.<group>
spec:
  group: ops.cka.io
  scope: Namespaced
  names:
    kind: Backup
    plural: backups
    singular: backup
    shortNames: [bk]
  versions:
  - name: v1
    served: true
    storage: true
    schema:
      openAPIV3Schema:
        type: object
        required: [spec]
        properties:
          spec:
            type: object
            required: [schedule]
            properties:
              schedule:
                type: string
              retentionDays:
                type: integer
                minimum: 1
```
```bash
kubectl config use-context main
kubectl apply -f crd.yaml
kubectl api-resources --api-group=ops.cka.io       # backups  bk  ops.cka.io/v1  true  Backup
kubectl explain backup.spec                         # your schema, served by the API server

cat <<EOF | kubectl apply -f -
apiVersion: ops.cka.io/v1
kind: Backup
metadata:
  name: nightly
  namespace: crd-lab
spec:
  schedule: "0 2 * * *"
  retentionDays: 7
EOF
kubectl -n crd-lab get bk

kubectl get crd | grep -E '^[a-z]+\.storage\.acme\.io '  # careful: ops.storage.acme.io is a different group
kubectl get crd -o jsonpath='{range .items[?(@.spec.group=="storage.acme.io")]}{.metadata.name}{"\n"}{end}' > {{ANSWERS}}/acme-storage-crds.txt
```
**Pitfalls:** quote the cron string (`*` is special in YAML). The CRD name must be `<plural>.<group>`.
A plain `grep storage.acme.io` also matches `archivejobs.ops.storage.acme.io`; filter on `.spec.group` (or `kubectl api-resources --api-group=storage.acme.io`).
