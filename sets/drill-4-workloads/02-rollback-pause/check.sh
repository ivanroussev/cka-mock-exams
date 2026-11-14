D="deploy/invoice-api -n billing"
# Names of the pods that aren't being deleted.
live_pods() { kubectl --context main -n billing get pods -l app=invoice-api -o go-template='{{range .items}}{{if not .metadata.deletionTimestamp}}{{.metadata.name}} {{end}}{{end}}'; }
export -f live_pods
check "3 Ready pods on nginx:1.27-alpine, without the env var" bash -c "
  n=0; for p in \$(live_pods); do
    [ \"\$(kubectl --context main -n billing get pod \$p -o jsonpath='{.spec.containers[0].image}|{.status.containerStatuses[0].ready}')\" = '$IMG_NGINX|true' ] || exit 1
    kubectl --context main -n billing get pod \$p -o jsonpath='{.spec.containers[0].env}' | grep -q FEATURE_INVOICE_PDF && exit 1
    n=\$((n+1)); done; [ \$n -eq 3 ]"
check "revision after the rollback written to file" bash -c "
  rev=\$(kubectl --context main get $D -o jsonpath='{.metadata.annotations.deployment\.kubernetes\.io/revision}')
  [ \"\$rev\" -ge 4 ] && file_eq '$ANSWERS/invoice-revision.txt' \"\$rev\""
check "deployment is paused" field_eq main "$D" '{.spec.paused}' true
check "FEATURE_INVOICE_PDF=on is in the pod template" field_eq main "$D" '{.spec.template.spec.containers[0].env[?(@.name=="FEATURE_INVOICE_PDF")].value}' on
