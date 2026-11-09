check "deployment db has 1 ready pod" deploy_ready main db shop-db 1
check "PVC db-data is Bound" field_eq main "pvc/db-data -n shop-db" '{.status.phase}' Bound
check "PVC db-data: class standard, 500Mi, single-node access mode" bash -c "kubectl --context main -n shop-db get pvc db-data -o jsonpath='{.spec.storageClassName}|{.spec.resources.requests.storage}|{.spec.accessModes}' | grep -qE '^standard\|500Mi\|\[\"ReadWriteOnce(Pod)?\"\]\$'"
check "pod template unchanged (redis, claim db-data)" bash -c "[ \"\$(kubectl --context main -n shop-db get deploy db -o jsonpath='{.spec.template.spec.containers[0].image}|{.spec.template.spec.volumes[0].persistentVolumeClaim.claimName}')\" = '$IMG_REDIS|db-data' ]"
