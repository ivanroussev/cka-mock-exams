source "$TASK_DIR/../lib.sh"
URL=http://orders-db.data:5432
check "orders-api pods in namespace orders can connect" reach_as main orders "app=orders-api" $URL "orders-db"
check "other pods in namespace orders are blocked" blocked_as main orders "app=reporting" $URL "orders-db"
check "orders-api pods in a namespace without team=orders are blocked" blocked_as main marketing "app=orders-api" $URL "orders-db"
check "policy allow-orders-api exists and deny-all-ingress is unchanged" bash -c "
  [ \"\$(kubectl --context main -n data get netpol allow-orders-api -o jsonpath='{.spec.podSelector.matchLabels.app}')\" = orders-db ] &&
  [ \"\$(kubectl --context main -n data get netpol deny-all-ingress -o jsonpath='{.spec.podSelector}|{.spec.policyTypes}|{.spec.ingress}')\" = '{}|[\"Ingress\"]|' ]"
