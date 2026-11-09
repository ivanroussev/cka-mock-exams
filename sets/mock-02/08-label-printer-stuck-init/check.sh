check "blocking container is wait-for-db" file_eq "$ANSWERS/label-printer-blocker.txt" "wait-for-db"
check "Service label-db (port 5432) has the label-db pods as endpoints" bash -c "
  [ \"\$(kubectl --context main -n shipping get svc label-db -o jsonpath='{.spec.ports[0].port}')\" = 5432 ] &&
  [ \$(kubectl --context main -n shipping get endpointslices -l kubernetes.io/service-name=label-db -o jsonpath='{range .items[*].endpoints[*]}{.addresses[0]}{\"\\n\"}{end}' | grep -c .) -ge 1 ]"
check "label-printer has 2 ready pods" deploy_ready main label-printer shipping 2
check "Deployments label-printer and label-db were not changed" bash -c "[ \"\$(kubectl --context main -n shipping get deploy label-printer label-db -o jsonpath='{range .items[*]}{.metadata.generation}{end}')\" = 11 ]"
