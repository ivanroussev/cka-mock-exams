J="job/nightly-export -n jobs"
check "shipper is a native sidecar (initContainer with restartPolicy Always)" bash -c "
  [ \"\$(kubectl --context main get $J -o jsonpath='{.spec.template.spec.initContainers[?(@.name==\"shipper\")].restartPolicy}')\" = Always ] &&
  [ -z \"\$(kubectl --context main get $J -o jsonpath='{.spec.template.spec.containers[?(@.name==\"shipper\")].name}')\" ] &&
  [ -n \"\$(kubectl --context main get $J -o jsonpath='{.spec.template.spec.containers[?(@.name==\"export\")].name}')\" ]"
check "restartPolicy Never and backoffLimit 2" field_eq main "$J" '{.spec.template.spec.restartPolicy}/{.spec.backoffLimit}' Never/2
check "job completed" field_eq main "$J" '{.status.conditions[?(@.type=="Complete")].status}' True
check "shipper logs contain 'exported batch 5'" bash -c "kubectl --context main -n jobs logs job/nightly-export -c shipper | grep -q 'exported batch 5'"
