check "PV records-archive is Bound to records/archive-data (same PV, still Retain)" bash -c "
  [ \"\$(kubectl --context main get pv records-archive -o jsonpath='{.status.phase} {.spec.claimRef.namespace}/{.spec.claimRef.name} {.spec.persistentVolumeReclaimPolicy}')\" = 'Bound records/archive-data Retain' ] &&
  [ \"\$(kubectl --context main get pv records-archive -o jsonpath='{.metadata.uid}')\" = \"\$(kubectl --context main get pv records-archive -o jsonpath='{.metadata.annotations.cka/original-uid}')\" ]"
check "PVC archive-data is Bound to records-archive" bash -c "[ \"\$(kubectl --context main -n records get pvc archive-data -o jsonpath='{.status.phase} {.spec.volumeName}')\" = 'Bound records-archive' ]"
check "pod archive-reader is Ready" pod_ready main archive-reader records
check "the archived data is visible read-only at /archive" bash -c "
  kubectl --context main -n records exec archive-reader -- cat /archive/index.txt | grep -q 'archive-2025 index' &&
  ! kubectl --context main -n records exec archive-reader -- touch /archive/.w"
