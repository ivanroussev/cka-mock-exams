```bash
kubectl config use-context alt
kubectl apply -f {{FILES}}/nightly-orders.yaml
#   no matches for kind "BackupPolicy" in version "dataops.example.com/v1"
kubectl get crd backuppolicies.dataops.example.com -o yaml | less     # versions: v1alpha1, the schema
kubectl explain backuppolicy.spec --recursive                         # works once you know the kind
```
Fixed file — four errors: the version, `cron` → `schedule`, `"30"` (string) → `30` (integer), `postgres` → `PostgreSQL` (enum):
```yaml
apiVersion: dataops.example.com/v1alpha1
kind: BackupPolicy
metadata: {name: nightly-orders, namespace: dataops}
spec:
  schedule: "30 1 * * *"
  retentionDays: 30
  target: {kind: PostgreSQL, name: orders}
```
```bash
kubectl edit crd backuppolicies.dataops.example.com
```
```yaml
spec:
  names:
    shortNames: [bp]
  versions:
  - name: v1alpha1
    additionalPrinterColumns:          # per version, next to "schema"
    - {name: Schedule,  type: string,  jsonPath: .spec.schedule}
    - {name: Retention, type: integer, jsonPath: .spec.retentionDays}
```
```bash
kubectl -n dataops get bp
```
**Tip:** the API server reports one class of error at a time (unknown version first, then schema errors together), so re-apply after each fix.
Column names are shown upper-case regardless of how you write them. Docs: "Extend the Kubernetes API with CustomResourceDefinitions → Additional printer columns".
