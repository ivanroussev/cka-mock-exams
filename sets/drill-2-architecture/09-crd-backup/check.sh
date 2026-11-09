C="crd/backups.ops.cka.io"
check "CRD backups.ops.cka.io is Established, Namespaced, kind Backup, short name bk" bash -c "
  [ \"\$(kubectl --context main get $C -o jsonpath='{.status.conditions[?(@.type==\"Established\")].status}|{.spec.scope}|{.spec.names.kind}|{.spec.names.singular}|{.spec.names.shortNames[*]}')\" = 'True|Namespaced|Backup|backup|bk' ]"
check "the schema rejects a Backup without schedule or with retentionDays 0" bash -c "
  ! printf 'apiVersion: ops.cka.io/v1\nkind: Backup\nmetadata: {name: chk-a, namespace: crd-lab}\nspec: {schedule: \"x\", retentionDays: 0}\n' | kubectl --context main create --dry-run=server -f - &&
  ! printf 'apiVersion: ops.cka.io/v1\nkind: Backup\nmetadata: {name: chk-b, namespace: crd-lab}\nspec: {retentionDays: 3}\n' | kubectl --context main create --dry-run=server -f - &&
  printf 'apiVersion: ops.cka.io/v1\nkind: Backup\nmetadata: {name: chk-c, namespace: crd-lab}\nspec: {schedule: \"x\", retentionDays: 3}\n' | kubectl --context main create --dry-run=server -f -"
check "Backup nightly in crd-lab has schedule '0 2 * * *' and retentionDays 7" bash -c "
  [ \"\$(kubectl --context main -n crd-lab get backups.ops.cka.io nightly -o jsonpath='{.spec.schedule}|{.spec.retentionDays}')\" = '0 2 * * *|7' ]"
check "acme-storage-crds.txt lists exactly the storage.acme.io CRDs" bash -c "
  [ \"\$(sed 's#^customresourcedefinition[^/]*/##' '$ANSWERS/acme-storage-crds.txt' | tr -d ' \t\r' | grep . | sort -u | tr '\n' ' ')\" = 'replicationpolicies.storage.acme.io tiers.storage.acme.io volumesnapshotpolicies.storage.acme.io ' ]"
