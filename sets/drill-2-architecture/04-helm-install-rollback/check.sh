rel() { helm --kube-context main -n "$1" list --filter "^$2\$" -o json 2>/dev/null; }
export -f rel
check "release frontend runs chart podinfo-6.16.0 in storefront" bash -c "rel storefront frontend | jq -e '.[0].chart == \"podinfo-6.16.0\" and .[0].status == \"deployed\"'"
check "frontend has 2 ready replicas" deploy_ready main frontend-podinfo storefront 2
check "frontend shows the message 'Welcome to CKA'" bash -c "[ \"\$(kubectl --context main -n storefront get deploy frontend-podinfo -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name==\"PODINFO_UI_MESSAGE\")].value}')\" = 'Welcome to CKA' ]"
check "catalog-revision.txt says 1" file_eq "$ANSWERS/catalog-revision.txt" 1
check "release catalog was rolled back with Helm to revision 1 and is healthy" bash -c "
  helm --kube-context main -n catalog history catalog -o json | jq -e 'last | .description == \"Rollback to 1\" and .status == \"deployed\"' &&
  [ \"\$(kubectl --context main -n catalog get deploy catalog-podinfo -o jsonpath='{.spec.template.spec.containers[0].image}')\" = ghcr.io/stefanprodan/podinfo:6.15.0 ] &&
  deploy_ready main catalog-podinfo catalog 1"
