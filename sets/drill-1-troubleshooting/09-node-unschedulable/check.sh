check "deployment reports has 2 ready pods" deploy_ready main reports ops 2
check "node $MAIN_W2 is schedulable" bash -c "[ -z \"\$(kubectl --context main get node $MAIN_W2 -o jsonpath='{.spec.unschedulable}')\" ]"
check "node $MAIN_W2 has no maintenance taint" bash -c "! kubectl --context main get node $MAIN_W2 -o jsonpath='{.spec.taints[*].key}' | grep -q maintenance"
check "deployment unchanged (nodeSelector disk=ssd, no tolerations)" bash -c "[ \"\$(kubectl --context main -n ops get deploy reports -o jsonpath='{.spec.template.spec.nodeSelector.disk}|{.spec.template.spec.tolerations}')\" = 'ssd|' ]"
