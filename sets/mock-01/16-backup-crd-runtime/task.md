A backup operator is about to be deployed. Its CustomResourceDefinition is in `{{FILES}}/backupschedules-crd.yaml`.

1. Install the CRD.
2. Create a `BackupSchedule` named `orders-nightly` in namespace `orders-ops` with:
   `schedule: "0 2 * * *"`, `retentionDays: 14`, `target: orders-db`.
3. Write the list of all CRDs in the API group `ops.example.com` — one name per line — to `{{ANSWERS}}/ops-crds.txt`.

The operator's install guide also asks two questions about node `cka-main-worker`:

4. Write the **container runtime endpoint** the kubelet on that node uses to `{{ANSWERS}}/cri-endpoint.txt`.
5. Write the **file name** (not the full path) of the CNI configuration file used on that node to `{{ANSWERS}}/cni-config.txt`.
