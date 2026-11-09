D="deploy/storefront -n web-shop"
check "good revision is 2" file_eq "$ANSWERS/storefront-good-revision.txt" 2
check "4 ready pods on nginx:1.28-alpine, no broken pods left" bash -c "
  [ \"\$(kubectl --context main get $D -o jsonpath='{.spec.template.spec.containers[0].image}')\" = '$IMG_NGINX2' ] &&
  [ \"\$(kubectl --context main get $D -o jsonpath='{.status.readyReplicas} {.status.updatedReplicas} {.status.replicas}')\" = '4 4 4' ] &&
  ! kubectl --context main -n web-shop get pods -l app=storefront -o jsonpath='{.items[*].spec.containers[0].image}' | grep -q perf"
check "strategy maxSurge 1 / maxUnavailable 0" bash -c "[ \"\$(kubectl --context main get $D -o jsonpath='{.spec.strategy.type} {.spec.strategy.rollingUpdate.maxSurge} {.spec.strategy.rollingUpdate.maxUnavailable}')\" = 'RollingUpdate 1 0' ]"
check "minReadySeconds 10, progressDeadlineSeconds 120" bash -c "[ \"\$(kubectl --context main get $D -o jsonpath='{.spec.minReadySeconds} {.spec.progressDeadlineSeconds}')\" = '10 120' ]"
check "THEME=winter rolled out with change cause 'enable winter theme'" bash -c "
  [ \"\$(kubectl --context main get $D -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name==\"THEME\")].value}|{.metadata.annotations.kubernetes\.io/change-cause}')\" = 'winter|enable winter theme' ] &&
  kubectl --context main -n web-shop rollout history $D | grep -q 'enable winter theme' &&
  [ \"\$(kubectl --context main get $D -o jsonpath='{.status.observedGeneration}')\" = \"\$(kubectl --context main get $D -o jsonpath='{.metadata.generation}')\" ]"
