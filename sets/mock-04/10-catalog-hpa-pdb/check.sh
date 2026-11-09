D="deploy/catalog-api -n product-api"; H="hpa/catalog-api -n product-api"
C='.spec.template.spec.containers[?(@.name=="api")]'
check "liveness probe: GET / :80, delay 10s, every 15s" bash -c "[ \"\$(kubectl --context main get $D -o jsonpath='{$C.livenessProbe.httpGet.path} {$C.livenessProbe.httpGet.port} {$C.livenessProbe.initialDelaySeconds} {$C.livenessProbe.periodSeconds}')\" = '/ 80 10 15' ]"
check "readiness probe: GET / :80 every 5s" bash -c "[ \"\$(kubectl --context main get $D -o jsonpath='{$C.readinessProbe.httpGet.path} {$C.readinessProbe.httpGet.port} {$C.readinessProbe.periodSeconds}')\" = '/ 80 5' ]"
check "HPA: 3–10 replicas, CPU 70% and memory 200Mi average" bash -c "
  [ \"\$(kubectl --context main get $H -o jsonpath='{.spec.scaleTargetRef.name} {.spec.minReplicas} {.spec.maxReplicas}')\" = 'catalog-api 3 10' ] &&
  [ \"\$(kubectl --context main get $H -o jsonpath='{.spec.metrics[?(@.resource.name==\"cpu\")].resource.target.type} {.spec.metrics[?(@.resource.name==\"cpu\")].resource.target.averageUtilization}')\" = 'Utilization 70' ] &&
  [ \"\$(kubectl --context main get $H -o jsonpath='{.spec.metrics[?(@.resource.name==\"memory\")].resource.target.type} {.spec.metrics[?(@.resource.name==\"memory\")].resource.target.averageValue}')\" = 'AverageValue 200Mi' ]"
check "HPA scale-up policy: max 2 pods per 60s; HPA active with 3+ replicas" bash -c "
  kubectl --context main get $H -o jsonpath='{range .spec.behavior.scaleUp.policies[*]}{.type}/{.value}/{.periodSeconds}{\"\n\"}{end}' | grep -qx 'Pods/2/60' &&
  [ \$(kubectl --context main get $H -o jsonpath='{range .spec.behavior.scaleUp.policies[*]}x{end}' | wc -c) -eq 1 ] &&
  [ \"\$(kubectl --context main get $H -o jsonpath='{.status.conditions[?(@.type==\"ScalingActive\")].status}')\" = True ] &&
  [ \"\$(kubectl --context main get $D -o jsonpath='{.status.readyReplicas}')\" -ge 3 ]"
check "PDB keeps 2 catalog-api pods available" bash -c "
  [ \"\$(kubectl --context main -n product-api get pdb catalog-api -o jsonpath='{.spec.minAvailable} {.status.expectedPods}')\" = \"2 \$(kubectl --context main get $D -o jsonpath='{.status.replicas}')\" ]"
