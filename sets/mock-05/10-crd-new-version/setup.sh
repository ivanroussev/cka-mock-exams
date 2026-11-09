schema='        openAPIV3Schema:
          type: object
          properties:
            spec:
              type: object
              required: [schedule]
              properties:
                schedule: {type: string}
                retention: {type: integer, minimum: 1}'
apply main <<YAML
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata: {name: backups.ops.example.com}
spec:
  group: ops.example.com
  scope: Namespaced
  names: {plural: backups, singular: backup, kind: Backup, shortNames: [bk]}
  versions:
  - name: v1alpha1
    served: true
    storage: true
    schema:
$schema
YAML
wait_for 60 kubectl --context main get crd backups.ops.example.com -o jsonpath='{.status.acceptedNames.kind}'
ns main ops-backup
wait_for 30 bash -c "kubectl --context main api-resources --api-group=ops.example.com | grep -q backups"
apply main <<'YAML'
apiVersion: ops.example.com/v1alpha1
kind: Backup
metadata: {name: legacy-weekly, namespace: ops-backup}
spec: {schedule: "0 3 * * 0", retention: 4}
YAML
# The vendor's new CRD definition — with a mistake in it.
cat > "$FILES/backups-crd-v1.yaml" <<YAML
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: backups.ops.example.com
spec:
  group: ops.example.com
  scope: Namespaced
  names:
    plural: backups
    singular: backup
    kind: Backup
    shortNames: [bk]
  versions:
  - name: v1alpha1
    served: true
    storage: true
    deprecated: true
    deprecationWarning: "ops.example.com/v1alpha1 Backup is deprecated; use ops.example.com/v1"
    schema:
$schema
  - name: v1
    served: true
    storage: true
    schema:
$schema
YAML
