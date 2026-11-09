The platform team wants a custom `Backup` resource on cluster `main`.

1. Create a CustomResourceDefinition with:
   - group `ops.cka.io`, version `v1` (served and stored), kind `Backup`, plural `backups`, singular `backup`, short name `bk`
   - scope **Namespaced**
   - a schema where `spec` is required and has:
     - `schedule`: string, **required**
     - `retentionDays`: integer, **minimum 1**
2. Create a `Backup` named `nightly` in namespace `crd-lab` with schedule `0 2 * * *` and `retentionDays` 7.
3. Some CRDs belonging to API group `storage.acme.io` are already installed. Write their names (one per line, as
   listed by `kubectl get crd`) to `{{ANSWERS}}/acme-storage-crds.txt`.
