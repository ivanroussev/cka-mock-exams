source "$TASK_DIR/../lib.sh"
check "ledger-api → http://ledger-db works (DNS + port 80 allowed)" reach_as main ledger "app=ledger-api" http://ledger-db "ledger-db"
check "other pods in ledger cannot reach ledger-db" blocked_as main ledger "app=intruder" http://ledger-db.ledger.svc.cluster.local "ledger-db"
check "ledger-api cannot reach anything outside (egress default deny)" blocked_as main ledger "app=ledger-api" http://partner.ledger-ext "partner"
check "default-deny covers ingress and egress for all pods" bash -c "
  [ \"\$(kubectl --context main -n ledger get netpol default-deny -o jsonpath='{.spec.podSelector}')\" = '{}' ] &&
  kubectl --context main -n ledger get netpol default-deny -o jsonpath='{.spec.policyTypes}' | grep -q Ingress &&
  kubectl --context main -n ledger get netpol default-deny -o jsonpath='{.spec.policyTypes}' | grep -q Egress"
check "a pod in another namespace with app=ledger-api cannot reach ledger-db" blocked_as main ledger-ext "app=ledger-api" http://ledger-db.ledger "ledger-db"
