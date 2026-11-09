check "PVC archive-claim is Bound to archive-pv" bash -c "[ \"\$(kubectl --context main -n archive get pvc archive-claim -o jsonpath='{.status.phase}|{.spec.volumeName}')\" = 'Bound|archive-pv' ]"
check "archive-pv still has reclaim policy Retain" field_eq main "pv/archive-pv" '{.spec.persistentVolumeReclaimPolicy}' Retain
check "pod archive-reader is Ready" pod_ready main archive-reader archive
check "the old data is visible at /archive/report.txt" bash -c "kubectl --context main -n archive exec archive-reader -- cat /archive/report.txt | grep -q 'revenue 4.2M'"
