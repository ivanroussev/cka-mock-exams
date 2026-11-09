D="deploy/quote-engine -n pricing"; H="hpa/quote-engine -n pricing"
check "requests are 100m CPU / 64Mi memory" bash -c "[ \"\$(kubectl --context main get $D -o jsonpath='{.spec.template.spec.containers[0].resources.requests.cpu} {.spec.template.spec.containers[0].resources.requests.memory}')\" = '100m 64Mi' ]"
check "limits are 250m CPU / 128Mi memory" bash -c "[ \"\$(kubectl --context main get $D -o jsonpath='{.spec.template.spec.containers[0].resources.limits.cpu} {.spec.template.spec.containers[0].resources.limits.memory}')\" = '250m 128Mi' ]"
check "HPA keeps 2–6 replicas at 65% CPU" bash -c "[ \"\$(kubectl --context main get $H -o jsonpath='{.spec.minReplicas} {.spec.maxReplicas} {.spec.metrics[0].resource.name} {.spec.metrics[0].resource.target.averageUtilization}')\" = '2 6 cpu 65' ]"
check "HPA scale-down stabilisation window is 120s" field_eq main "$H" '{.spec.behavior.scaleDown.stabilizationWindowSeconds}' 120
check "HPA reports CPU utilisation (ScalingActive) and was not recreated" bash -c "
  [ \"\$(kubectl --context main get $H -o jsonpath='{.status.conditions[?(@.type==\"ScalingActive\")].status}')\" = True ] &&
  [ -n \"\$(kubectl --context main get $H -o jsonpath='{.status.currentMetrics[0].resource.current.averageUtilization}')\" ] &&
  [ \"\$(kubectl --context main get $H -o jsonpath='{.metadata.uid}')\" = \"\$(kubectl --context main get $H -o jsonpath='{.metadata.annotations.cka/original-uid}')\" ]"
