ns main crd-lab
# Install a few CRDs: three in storage.acme.io, plus look-alikes in other groups.
mkcrd() { # mkcrd <group> <kind> <plural>
  apply main <<YAML
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata: {name: $3.$1}
spec:
  group: $1
  scope: Namespaced
  names: {kind: $2, plural: $3, singular: $(echo "$2" | tr 'A-Z' 'a-z'), listKind: ${2}List}
  versions:
  - name: v1alpha1
    served: true
    storage: true
    schema:
      openAPIV3Schema:
        type: object
        x-kubernetes-preserve-unknown-fields: true
YAML
}
mkcrd storage.acme.io VolumeSnapshotPolicy volumesnapshotpolicies
mkcrd storage.acme.io ReplicationPolicy replicationpolicies
mkcrd storage.acme.io Tier tiers
mkcrd backup.acme.io Vault vaults
mkcrd acme.io StoragePool storagepools
mkcrd ops.storage.acme.io ArchiveJob archivejobs
