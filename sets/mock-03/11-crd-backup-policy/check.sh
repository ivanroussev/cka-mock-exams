C="crd/backuppolicies.dataops.example.com"
check "BackupPolicy nightly-orders exists in dataops with the intended spec" bash -c "
  [ \"\$(kubectl --context alt -n dataops get backuppolicies.dataops.example.com nightly-orders -o jsonpath='{.spec.schedule}|{.spec.retentionDays}|{.spec.target.kind}|{.spec.target.name}')\" = '30 1 * * *|30|PostgreSQL|orders' ]"
check "the fixed file creates that object" bash -c "kubectl --context alt apply --dry-run=server -f '$FILES/nightly-orders.yaml' >/dev/null && grep -q 'dataops.example.com/v1alpha1' '$FILES/nightly-orders.yaml'"
check "short name bp" bash -c "kubectl --context alt get $C -o jsonpath='{.spec.names.shortNames}' | grep -q '\"bp\"' && kubectl --context alt -n dataops get bp nightly-orders"
check "printer columns SCHEDULE and RETENTION" bash -c "
  kubectl --context alt get $C -o jsonpath='{range .spec.versions[?(@.name==\"v1alpha1\")].additionalPrinterColumns[*]}{.jsonPath}{\"\n\"}{end}' | grep -qx '.spec.schedule' &&
  kubectl --context alt get $C -o jsonpath='{range .spec.versions[?(@.name==\"v1alpha1\")].additionalPrinterColumns[*]}{.jsonPath}{\"\n\"}{end}' | grep -qx '.spec.retentionDays' &&
  kubectl --context alt -n dataops get backuppolicies | head -1 | grep -q SCHEDULE && kubectl --context alt -n dataops get backuppolicies | head -1 | grep -q RETENTION"
