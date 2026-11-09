D="deploy/ledger-ui -n probes"
C='{.spec.template.spec.containers[0]'
check "startup probe: HTTP / on 80 every 5s, allows >= 60s" bash -c "
  [ \"\$(kubectl --context main get $D -o jsonpath='$C.startupProbe.httpGet.path}|$C.startupProbe.httpGet.port}|$C.startupProbe.periodSeconds}')\" = '/|80|5' ] &&
  ft=\$(kubectl --context main get $D -o jsonpath='$C.startupProbe.failureThreshold}') && [ \$((ft * 5)) -ge 60 ]"
check "readiness probe: HTTP / on 80 every 5s" field_eq main "$D" "$C.readinessProbe.httpGet.path}|$C.readinessProbe.httpGet.port}|$C.readinessProbe.periodSeconds}" '/|80|5'
check "liveness probe and command unchanged" bash -c "
  [ \"\$(kubectl --context main get $D -o jsonpath='$C.livenessProbe.httpGet.port}|$C.livenessProbe.periodSeconds}|$C.livenessProbe.failureThreshold}')\" = '80|5|3' ] &&
  kubectl --context main get $D -o jsonpath='$C.command}' | grep -q 'sleep 40'"
check "2 pods Ready with no restarts" bash -c "
  [ \"\$(kubectl --context main get $D -o jsonpath='{.status.readyReplicas}/{.status.updatedReplicas}')\" = 2/2 ] &&
  [ \"\$(kubectl --context main -n probes get pods -l app=ledger-ui -o go-template='{{range .items}}{{if not .metadata.deletionTimestamp}}{{range .status.containerStatuses}}{{.restartCount}} {{end}}{{end}}{{end}}')\" = '0 0 ' ]"
