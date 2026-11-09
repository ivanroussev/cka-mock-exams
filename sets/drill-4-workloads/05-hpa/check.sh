H="hpa/cruncher -n autoscale"
check "container requests 100m CPU, limit 250m" field_eq main "deploy/cruncher -n autoscale" \
  '{.spec.template.spec.containers[0].resources.requests.cpu}/{.spec.template.spec.containers[0].resources.limits.cpu}' 100m/250m
check "HPA targets deployment cruncher, 2-6 replicas, 60% CPU utilization" bash -c "
  [ \"\$(kubectl --context main get $H -o jsonpath='{.spec.scaleTargetRef.kind}/{.spec.scaleTargetRef.name}/{.spec.minReplicas}/{.spec.maxReplicas}')\" = Deployment/cruncher/2/6 ] &&
  [ \"\$(kubectl --context main get $H -o jsonpath='{.spec.metrics[?(@.resource.name==\"cpu\")].resource.target.type}/{.spec.metrics[?(@.resource.name==\"cpu\")].resource.target.averageUtilization}')\" = Utilization/60 ]"
check "scale-down stabilization window is 120s" field_eq main "$H" '{.spec.behavior.scaleDown.stabilizationWindowSeconds}' 120
check "HPA reads CPU utilization and runs at least 2 replicas" bash -c "
  [ \"\$(kubectl --context main get $H -o jsonpath='{.status.conditions[?(@.type==\"ScalingActive\")].status}')\" = True ] &&
  [ -n \"\$(kubectl --context main get $H -o jsonpath='{.status.currentMetrics[0].resource.current.averageUtilization}')\" ] &&
  [ \"\$(kubectl --context main -n autoscale get deploy cruncher -o jsonpath='{.status.readyReplicas}')\" -ge 2 ]"
