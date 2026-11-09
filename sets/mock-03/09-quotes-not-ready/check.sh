web() { kubectl --context main -n quotes run "chk-$RANDOM$RANDOM" --image="$IMG_CURL" --restart=Never --rm -i --quiet --command -- sh -c "sleep 1; curl -s -m 4 $1" 2>/dev/null; }
export -f web
check "both quotes pods are Ready" deploy_ready main quotes quotes 2
check "readiness probe still checks HTTP /healthz" field_eq main "deploy/quotes -n quotes" '{.spec.template.spec.containers[0].readinessProbe.httpGet.path}' /healthz
check "Service quotes (port 80) has 2 ready endpoints" bash -c "
  [ \"\$(kubectl --context main -n quotes get svc quotes -o jsonpath='{.spec.ports[0].port}')\" = 80 ] &&
  [ \$(kubectl --context main -n quotes get endpointslices -l kubernetes.io/service-name=quotes -o jsonpath='{range .items[*].endpoints[?(@.conditions.ready==true)]}{.addresses[0]}{\"\n\"}{end}' | grep -c .) -eq 2 ]"
check "http://quotes.quotes/healthz returns ok" bash -c "web http://quotes.quotes/healthz | grep -qx ok"
