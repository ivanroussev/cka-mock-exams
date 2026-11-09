check "StorageClass resizable allows volume expansion" field_eq main "sc/resizable" '{.allowVolumeExpansion}' true
check "PVC report-data requests 2Gi" field_eq main "pvc/report-data -n reports" '{.spec.resources.requests.storage}' 2Gi
check "PVC report-data is the original one, still Bound" bash -c "[ \"\$(kubectl --context main -n reports get pvc report-data -o jsonpath='{.metadata.uid}|{.status.phase}')\" = \"\$(kubectl --context main get ns reports -o jsonpath='{.metadata.annotations.cka/pvc-uid}')|Bound\" ]"
