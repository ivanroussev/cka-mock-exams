check "OOMKilled deployment named" file_eq "$ANSWERS/triage-oom.txt" "ledger"
check "image pull failure deployment named" file_eq "$ANSWERS/triage-image.txt" "catalog"
check "gateway is Ready" deploy_ready main gateway triage 1
check "gateway still has a liveness and a readiness probe" bash -c "[ -n \"\$(kubectl --context main -n triage get deploy gateway -o jsonpath='{.spec.template.spec.containers[0].livenessProbe.periodSeconds}')\" ] && [ -n \"\$(kubectl --context main -n triage get deploy gateway -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.periodSeconds}')\" ]"
