The backup operator's CRD `backups.ops.example.com` currently serves only version `v1alpha1`. The vendor ships a new definition
that adds version `v1` in `{{FILES}}/backups-crd-v1.yaml`, but the API server rejects it.

1. Fix the file as needed and apply it so that:
   - `v1` is served **and** is the storage version;
   - `v1alpha1` is still served (marked deprecated, as in the file) but is no longer the storage version.
2. Create a Backup named `nightly` in namespace `ops-backup` using API version `ops.example.com/v1`, with `schedule: "30 1 * * *"` and `retention: 14`.

The existing Backup `legacy-weekly` must keep working.
