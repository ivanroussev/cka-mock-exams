D="deploy/storefront -n rollout"
check "strategy maxSurge=1, maxUnavailable=0" bash -c "[ \"\$(kubectl --context main get $D -o jsonpath='{.spec.strategy.rollingUpdate.maxSurge}/{.spec.strategy.rollingUpdate.maxUnavailable}')\" = 1/0 ]"
check "all 4 replicas run nginx:1.28-alpine" bash -c "
  [ \"\$(kubectl --context main get $D -o jsonpath='{.spec.template.spec.containers[0].image}')\" = '$IMG_NGINX2' ] &&
  [ \"\$(kubectl --context main get $D -o jsonpath='{.status.updatedReplicas}/{.status.readyReplicas}/{.status.replicas}')\" = 4/4/4 ]"
check "change cause recorded on the current revision" bash -c "
  rev=\$(kubectl --context main get $D -o jsonpath='{.metadata.annotations.deployment\.kubernetes\.io/revision}')
  [ \"\$rev\" -ge 2 ] && kubectl --context main -n rollout rollout history deploy/storefront | awk -v r=\"\$rev\" '\$1==r' | grep -q 'upgrade nginx to 1.28'"
check "revision number written to file" bash -c "
  rev=\$(kubectl --context main get $D -o jsonpath='{.metadata.annotations.deployment\.kubernetes\.io/revision}')
  [ \"\$rev\" -ge 2 ] && file_eq '$ANSWERS/storefront-revision.txt' \"\$rev\""
