apply main <<'YAML'
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: backups.ops.cka.io
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
YAML
kc main wait --for=condition=Established crd/backups.ops.cka.io --timeout=60s
wait_for 60 bash -c "kubectl --context main apply -f - <<'YAML'
apiVersion: ops.cka.io/v1
kind: Backup
metadata: {name: nightly, namespace: crd-lab}
spec:
  schedule: '0 2 * * *'
  retentionDays: 7
YAML"
kc main get crd -o jsonpath='{range .items[?(@.spec.group=="storage.acme.io")]}{.metadata.name}{"\n"}{end}' > "$ANSWERS/acme-storage-crds.txt"
