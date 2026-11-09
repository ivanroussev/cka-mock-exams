check "PVC uploads-data: Bound, ReadWriteOncePod, 2Gi, standard" bash -c "
  [ \"\$(kubectl --context main -n uploads get pvc uploads-data -o jsonpath='{.status.phase} {.spec.accessModes} {.spec.resources.requests.storage} {.spec.storageClassName}')\" = 'Bound [\"ReadWriteOncePod\"] 2Gi standard' ]"
check "uploader is running with the claim mounted at /data" bash -c "
  deploy_ready main uploader uploads 1 && kubectl --context main -n uploads exec deploy/uploader -- cat /data/started.log | grep -q ."
check "update strategy is Recreate" field_eq main "deploy/uploader -n uploads" '{.spec.strategy.type}' Recreate
