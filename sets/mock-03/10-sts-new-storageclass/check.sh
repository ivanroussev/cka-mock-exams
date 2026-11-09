check "StorageClass local-retain (local-path, Retain, WaitForFirstConsumer, not default)" bash -c "
  [ \"\$(kubectl --context main get sc local-retain -o jsonpath='{.provisioner} {.reclaimPolicy} {.volumeBindingMode} {.metadata.annotations.storageclass\.kubernetes\.io/is-default-class}')\" = 'rancher.io/local-path Retain WaitForFirstConsumer ' ] ||
  [ \"\$(kubectl --context main get sc local-retain -o jsonpath='{.provisioner} {.reclaimPolicy} {.volumeBindingMode} {.metadata.annotations.storageclass\.kubernetes\.io/is-default-class}')\" = 'rancher.io/local-path Retain WaitForFirstConsumer false' ]"
check "quorum's claim template data uses local-retain (1Gi)" bash -c "[ \"\$(kubectl --context main -n consensus get sts quorum -o jsonpath='{.spec.volumeClaimTemplates[0].metadata.name} {.spec.volumeClaimTemplates[0].spec.storageClassName} {.spec.volumeClaimTemplates[0].spec.resources.requests.storage}')\" = 'data local-retain 1Gi' ]"
check "quorum has 3 ready replicas on Bound local-retain claims" bash -c "
  [ \"\$(kubectl --context main -n consensus get sts quorum -o jsonpath='{.status.readyReplicas}')\" = 3 ] &&
  for i in 0 1 2; do [ \"\$(kubectl --context main -n consensus get pvc data-quorum-\$i -o jsonpath='{.spec.storageClassName} {.status.phase}')\" = 'local-retain Bound' ] || exit 1; done"
check "no standard PVCs left in consensus" bash -c "! kubectl --context main -n consensus get pvc -o jsonpath='{.items[*].spec.storageClassName}' | grep -qw standard"
