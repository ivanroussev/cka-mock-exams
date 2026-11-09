ns alt dataops
apply alt <<'YAML'
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata: {name: backuppolicies.dataops.example.com}
spec:
  group: dataops.example.com
  scope: Namespaced
  names: {kind: BackupPolicy, plural: backuppolicies, singular: backuppolicy, listKind: BackupPolicyList}
  versions:
  - name: v1alpha1
    served: true
    storage: true
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
            required: [schedule, target, retentionDays]
            properties:
              schedule: {type: string, description: "cron expression, e.g. '0 2 * * *'"}
              retentionDays: {type: integer, minimum: 1, maximum: 90}
              target:
                type: object
                required: [kind, name]
                properties:
                  kind: {type: string, enum: [PostgreSQL, MySQL, Redis]}
                  name: {type: string}
              suspend: {type: boolean}
YAML
kubectl --context alt wait --for=condition=Established crd/backuppolicies.dataops.example.com --timeout=60s >/dev/null
cat > "$FILES/nightly-orders.yaml" <<'YAML'
apiVersion: dataops.example.com/v1
kind: BackupPolicy
metadata:
  name: nightly-orders
  namespace: dataops
spec:
  cron: "30 1 * * *"
  retentionDays: "30"
  target:
    kind: postgres
    name: orders
YAML
