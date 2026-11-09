```bash
kubectl apply -f {{FILES}}/backups-crd-v1.yaml
#   → spec.versions: Invalid value: …: must have exactly one version marked as storage version
vim {{FILES}}/backups-crd-v1.yaml           # v1alpha1: storage: false   (v1 keeps storage: true)
kubectl apply -f {{FILES}}/backups-crd-v1.yaml
kubectl get crd backups.ops.example.com -o jsonpath='{range .spec.versions[*]}{.name} served={.served} storage={.storage}{"\n"}{end}'
kubectl api-resources --api-group=ops.example.com
kubectl explain backups.spec --api-version=ops.example.com/v1

cat <<'YAML' | kubectl apply -f -
apiVersion: ops.example.com/v1
kind: Backup
metadata: {name: nightly, namespace: ops-backup}
spec: {schedule: "30 1 * * *", retention: 14}
YAML
kubectl -n ops-backup get backups.v1alpha1.ops.example.com    # works, with a deprecation warning
kubectl -n ops-backup get bk
```
Docs: *Extend Kubernetes → Custom Resources → Versions in CustomResourceDefinitions*.
**Why:** a CRD can serve many versions but stores objects in exactly **one**. Old objects stay stored as `v1alpha1`
(`status.storedVersions` lists both) until they are rewritten; with `conversion: None` the API server just swaps the `apiVersion`,
which only works because both versions have the same schema.
