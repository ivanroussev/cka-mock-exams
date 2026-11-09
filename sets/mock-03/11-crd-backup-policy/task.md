The data team's backup operator defines the custom resource `BackupPolicy` (CRD `backuppolicies.dataops.example.com`), already installed in this cluster.

1. The manifest `{{FILES}}/nightly-orders.yaml` is rejected by the API server. Fix the file so it matches the CRD's schema — keep its intent
   (run at 01:30 every night, back up the PostgreSQL database `orders`, keep backups for 30 days) — and create the object in namespace `dataops`.
2. Update the CRD so that:
   - `kubectl get bp` works as a short name for BackupPolicies, and
   - `kubectl get backuppolicies` shows two extra columns, `SCHEDULE` (from `.spec.schedule`) and `RETENTION` (from `.spec.retentionDays`).
