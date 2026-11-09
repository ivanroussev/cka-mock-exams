web() { kubectl --context main -n "$1" run "chk-$RANDOM$RANDOM" --image="$IMG_CURL" --restart=Never --rm -i --quiet --command -- sh -c "sleep 1; curl -s -m 4 $2" 2>/dev/null; }
export -f web
IP=$(kubectl --context main -n erp get pod erp-legacy -o jsonpath='{.status.podIP}')
check "pod IP written" file_eq "$ANSWERS/erp-ip.txt" "$IP"
check "Service erp (port 80) has no selector; EndpointSlice erp-1 points at the pod" bash -c "
  [ -z \"\$(kubectl --context main -n erp get svc erp -o jsonpath='{.spec.selector}')\" ] &&
  [ \"\$(kubectl --context main -n erp get svc erp -o jsonpath='{.spec.ports[0].port}')\" = 80 ] &&
  [ \"\$(kubectl --context main -n erp get endpointslice erp-1 -o jsonpath='{.metadata.labels.kubernetes\.io/service-name} {.addressType} {.endpoints[*].addresses[*]} {.ports[0].port}')\" = 'erp IPv4 $IP 80' ]"
check "http://erp.erp answers from the legacy pod" bash -c "web erp http://erp.erp | grep -q 'ERP 7.4 legacy'"
check "finance can call http://erp-gateway (ExternalName)" bash -c "
  [ \"\$(kubectl --context main -n finance get svc erp-gateway -o jsonpath='{.spec.type}')\" = ExternalName ] &&
  case \"\$(kubectl --context main -n finance get svc erp-gateway -o jsonpath='{.spec.externalName}')\" in erp.erp.svc.cluster.local|erp.erp.svc.cluster.local.|erp.erp.svc|erp.erp) ;; *) exit 1;; esac &&
  web finance http://erp-gateway | grep -q 'ERP 7.4 legacy'"
check "pod erp-legacy unchanged (no labels, not recreated)" bash -c "[ -z \"\$(kubectl --context main -n erp get pod erp-legacy -o jsonpath='{.metadata.labels}')\" ] && [ \"\$(kubectl --context main -n erp get pod erp-legacy -o jsonpath='{.status.containerStatuses[0].restartCount}')\" = 0 ]"
