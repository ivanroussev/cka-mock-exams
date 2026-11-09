D="deploy/trainer -n ml"
check "PriorityClass ml-batch (50000, Never, not default)" bash -c "
  [ \"\$(kubectl --context main get priorityclass ml-batch -o jsonpath='{.value} {.preemptionPolicy} {.globalDefault} {.description}')\" = '50000 Never false ML training jobs' ] ||
  [ \"\$(kubectl --context main get priorityclass ml-batch -o jsonpath='{.value} {.preemptionPolicy} {.globalDefault}|{.description}')\" = '50000 Never |ML training jobs' ]"
check "trainer has 2 ready pods, all on $MAIN_W2" bash -c "
  deploy_ready main trainer ml 2 &&
  [ \"\$(kubectl --context main -n ml get pods -l app=trainer --field-selector=status.phase=Running -o jsonpath='{range .items[*]}{.spec.nodeName}{\"\n\"}{end}' | sort -u)\" = '$MAIN_W2' ]"
check "placement uses required node affinity pool=ml, no nodeSelector" bash -c "
  [ -z \"\$(kubectl --context main get $D -o jsonpath='{.spec.template.spec.nodeSelector}')\" ] &&
  kubectl --context main get $D -o jsonpath='{range .spec.template.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[*].matchExpressions[*]}{.key} {.operator} {.values}{\"\n\"}{end}' | grep -Eq '^pool (In \[\"ml\"\]|In \[\"ml\".*\])\$'"
check "toleration matches workload=ml:NoSchedule" bash -c "
  kubectl --context main get $D -o jsonpath='{range .spec.template.spec.tolerations[*]}{.key},{.operator},{.value},{.effect}{\"\n\"}{end}' | grep -Eq '^workload,(Equal)?,ml,NoSchedule\$|^workload,Exists,,NoSchedule\$'"
check "trainer pods use priority class ml-batch" bash -c "
  [ \"\$(kubectl --context main get $D -o jsonpath='{.spec.template.spec.priorityClassName}')\" = ml-batch ] &&
  [ \"\$(kubectl --context main -n ml get pods -l app=trainer -o jsonpath='{range .items[*]}{.spec.priority}{\"\n\"}{end}' | sort -u)\" = 50000 ]"
