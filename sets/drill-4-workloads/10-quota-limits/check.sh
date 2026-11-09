check "LimitRange container-defaults has the requested defaults" field_eq main "limitrange/container-defaults -n team-a" \
  '{.spec.limits[?(@.type=="Container")].defaultRequest.cpu}/{.spec.limits[?(@.type=="Container")].defaultRequest.memory}/{.spec.limits[?(@.type=="Container")].default.cpu}/{.spec.limits[?(@.type=="Container")].default.memory}' 100m/64Mi/200m/128Mi
check "ResourceQuota team-a-quota: pods 3, requests.cpu 1, limits.memory 1Gi" field_eq main "resourcequota/team-a-quota -n team-a" \
  '{.spec.hard.pods}/{.spec.hard.requests\.cpu}/{.spec.hard.limits\.memory}' 3/1/1Gi
check "PriorityClass team-a-high = 100000, not global default" bash -c "
  [ \"\$(kubectl --context main get priorityclass team-a-high -o jsonpath='{.value}|{.globalDefault}')\" = '100000|' ] ||
  [ \"\$(kubectl --context main get priorityclass team-a-high -o jsonpath='{.value}|{.globalDefault}')\" = '100000|false' ]"
check "worker: 3 Ready pods with priority 100000 and the default limits" bash -c "
  [ \"\$(kubectl --context main -n team-a get deploy worker -o jsonpath='{.spec.replicas}|{.status.readyReplicas}|{.spec.template.spec.priorityClassName}')\" = '4|3|team-a-high' ] &&
  [ -z \"\$(kubectl --context main -n team-a get deploy worker -o jsonpath='{.spec.template.spec.containers[0].resources.limits}')\" ] &&
  p=\$(kubectl --context main -n team-a get pods -l app=worker -o jsonpath='{.items[0].metadata.name}') &&
  [ \"\$(kubectl --context main -n team-a get pod \$p -o jsonpath='{.spec.priority}|{.spec.containers[0].resources.limits.cpu}|{.spec.containers[0].resources.requests.memory}')\" = '100000|200m|64Mi' ]"
check "quota error message written to file" bash -c "grep -q 'exceeded quota' '$ANSWERS/quota-error.txt' && grep -q 'team-a-quota' '$ANSWERS/quota-error.txt'"
