check "log-agent runs a Ready pod on all 3 nodes, including the control plane" bash -c "
  [ \"\$(kubectl --context main -n ops get ds log-agent -o jsonpath='{.status.desiredNumberScheduled}|{.status.numberReady}|{.status.updatedNumberScheduled}')\" = '3|3|3' ] &&
  kubectl --context main -n ops get pods -l app=log-agent -o jsonpath='{range .items[*]}{.spec.nodeName}{\"\n\"}{end}' | grep -qx '$MAIN_CP'"
check "control-plane taint still in place" bash -c "kubectl --context main get node $MAIN_CP -o jsonpath='{.spec.taints[*].key}' | grep -q node-role.kubernetes.io/control-plane"
check "taints of worker2 saved to file" bash -c "grep -q 'workload=ml:NoSchedule' '$ANSWERS/worker2-taints.txt'"
check "trainer: 2 Running pods on worker2 that tolerate workload=ml:NoSchedule" bash -c "
  d=\$(kubectl --context main -n ops get deploy trainer -o jsonpath='{range .spec.template.spec.tolerations[*]}{.key}|{.operator}|{.value}|{.effect}{\"\n\"}{end}')
  echo \"\$d\" | grep -Eq '^workload\|(Equal)?\|ml\|(NoSchedule)?$|^workload\|Exists\|\|(NoSchedule)?$' &&
  [ \"\$(kubectl --context main -n ops get pods -l app=trainer --field-selector=status.phase=Running -o jsonpath='{range .items[*]}{.spec.nodeName}{\"\n\"}{end}' | sort | uniq -c | awk '{print \$1\" \"\$2}')\" = '2 $MAIN_W2' ]"
check "taint removed from worker2" bash -c "! kubectl --context main get node $MAIN_W2 -o jsonpath='{.spec.taints[*].key}' | grep -q workload"
