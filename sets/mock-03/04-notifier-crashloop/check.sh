D="deploy/notifier -n alerts"
check "FATAL line saved" bash -c "grep -q 'FATAL: SMTP_PASSWORD is empty' '$ANSWERS/notifier-fatal.txt' && [ \$(grep -c . '$ANSWERS/notifier-fatal.txt') -le 2 ]"
check "SMTP_PASSWORD comes from secret smtp-credentials key password" bash -c "[ \"\$(kubectl --context main get $D -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name==\"SMTP_PASSWORD\")].valueFrom.secretKeyRef.name}/{.spec.template.spec.containers[0].env[?(@.name==\"SMTP_PASSWORD\")].valueFrom.secretKeyRef.key}')\" = smtp-credentials/password ]"
# Accept envFrom, or one configMapKeyRef per key (what `kubectl set env --from=configmap/…` produces).
check "every key of notifier-config is exposed as env" bash -c "
  field_has main '$D' '{.spec.template.spec.containers[0].envFrom[*].configMapRef.name}' notifier-config && exit 0
  for k in SMTP_HOST SMTP_PORT ALERT_CHANNEL; do
    [ \"\$(kubectl --context main get $D -o jsonpath=\"{.spec.template.spec.containers[0].env[?(@.name==\\\"\$k\\\")].valueFrom.configMapKeyRef.name}\")\" = notifier-config ] || exit 1
  done"
check "notifier is running and connected" bash -c "deploy_ready main notifier alerts 1 && kubectl --context main -n alerts logs deploy/notifier | grep -q 'connected to smtp.relay.internal:587, alerts go to ops-pager'"
check "secret and configmap unchanged" bash -c "[ \"\$(kubectl --context main -n alerts get secret smtp-credentials -o jsonpath='{.data.password}' | base64 --decode)\" = Tr0ub4dor-77 ] && [ \"\$(kubectl --context main -n alerts get cm notifier-config -o jsonpath='{.data.SMTP_HOST}')\" = smtp.relay.internal ]"
