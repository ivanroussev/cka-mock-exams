P="pod/analytics -n resize"
check "pod analytics was not recreated" bash -c "[ -s '$STATE/drill4-analytics-uid' ] && [ \"\$(kubectl --context main get $P -o jsonpath='{.metadata.uid}')\" = \"\$(cat '$STATE/drill4-analytics-uid')\" ]"
check "spec: cpu 300m/500m, memory limit 256Mi, memory request 64Mi" field_eq main "$P" \
  '{.spec.containers[0].resources.requests.cpu}/{.spec.containers[0].resources.limits.cpu}/{.spec.containers[0].resources.limits.memory}/{.spec.containers[0].resources.requests.memory}' 300m/500m/256Mi/64Mi
check "running container has the new CPU and memory values" field_eq main "$P" \
  '{.status.containerStatuses[0].resources.requests.cpu}/{.status.containerStatuses[0].resources.limits.cpu}/{.status.containerStatuses[0].resources.limits.memory}' 300m/500m/256Mi
check "restart count written to file" bash -c "
  rc=\$(kubectl --context main get $P -o jsonpath='{.status.containerStatuses[0].restartCount}')
  [ \"\$rc\" -ge 1 ] && file_eq '$ANSWERS/analytics-restarts.txt' \"\$rc\""
