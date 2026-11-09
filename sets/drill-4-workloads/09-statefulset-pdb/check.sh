check "headless Service kv on 6379 selecting app=kv" field_eq main "svc/kv -n kv" '{.spec.clusterIP}|{.spec.selector.app}|{.spec.ports[0].port}' 'None|kv|6379'
check "StatefulSet kv: 3 Ready pods kv-0..kv-2 on redis:7-alpine, serviceName kv" bash -c "
  [ \"\$(kubectl --context main -n kv get sts kv -o jsonpath='{.spec.serviceName}|{.status.readyReplicas}|{.spec.template.spec.containers[0].image}')\" = 'kv|3|$IMG_REDIS' ] &&
  for i in 0 1 2; do pod_ready main kv-\$i kv || exit 1; done"
check "kv-0 reaches kv-1 by its stable DNS name" bash -c "
  [ \"\$(kubectl --context main -n kv exec kv-0 -- redis-cli -h kv-1.kv.kv.svc.cluster.local ping)\" = PONG ]"
check "PDB kv-pdb keeps 2 of the 3 kv pods available" bash -c "
  [ \"\$(kubectl --context main -n kv get pdb kv-pdb -o jsonpath='{.status.desiredHealthy}|{.status.expectedPods}')\" = '2|3' ]"
check "FQDN of the second replica written to file" bash -c "
  f=\$(tr -d '[:space:]' < '$ANSWERS/kv-replica.txt'); [ \"\${f%.}\" = kv-1.kv.kv.svc.cluster.local ]"
