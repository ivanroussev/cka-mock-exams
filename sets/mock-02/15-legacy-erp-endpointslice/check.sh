source "$TASK_DIR/../lib.sh"
check "http://erp.legacy returns the ERP backend" bash -c "curl_pod main legacy http://erp.legacy | grep -q 'erp backend v7'"
check "EndpointSlice erp-manual points at erp-backend's IP, port 8080" bash -c "
  ip=\$(kubectl --context main -n legacy get pod erp-backend -o jsonpath='{.status.podIP}') &&
  [ \"\$(kubectl --context main -n legacy get endpointslice erp-manual -o jsonpath='{.endpoints[*].addresses[*]}|{.ports[0].port}|{.metadata.labels.kubernetes\.io/service-name}')\" = \"\$ip|8080|erp\" ]"
check "Service erp still has no selector, pod unchanged" bash -c "[ -z \"\$(kubectl --context main -n legacy get svc erp -o jsonpath='{.spec.selector}')\" ] && [ \"\$(kubectl --context main -n legacy get pod erp-backend -o jsonpath='{.metadata.labels}')\" = '{\"app\":\"erp-backend\"}' ]"
