ns main orders-ops
for kind in BackupSchedule:backupschedules:bs RestoreJob:restorejobs:rj; do
  K=${kind%%:*}; rest=${kind#*:}; P=${rest%%:*}; S=${rest#*:}
  f="$FILES/$P-crd.yaml"
  cat > "$f" <<YAML
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: $P.ops.example.com
spec:
  group: ops.example.com
  scope: Namespaced
  names: {kind: $K, plural: $P, singular: $(echo $K | tr 'A-Z' 'a-z'), shortNames: [$S]}
  versions:
  - name: v1
    served: true
    storage: true
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
            required: [target]
            properties:
              schedule: {type: string}
              retentionDays: {type: integer, minimum: 1}
              target: {type: string}
YAML
done
# The RestoreJob CRD is already installed; the BackupSchedule one is the learner's job.
kubectl --context main apply -f "$FILES/restorejobs-crd.yaml" >/dev/null
rm -f "$FILES/restorejobs-crd.yaml"
# An unrelated CRD in a look-alike group.
apply main <<'YAML'
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata: {name: dashboards.ops.example.org}
spec:
  group: ops.example.org
  scope: Namespaced
  names: {kind: Dashboard, plural: dashboards, singular: dashboard}
  versions:
  - name: v1
    served: true
    storage: true
    schema: {openAPIV3Schema: {type: object, x-kubernetes-preserve-unknown-fields: true}}
YAML
