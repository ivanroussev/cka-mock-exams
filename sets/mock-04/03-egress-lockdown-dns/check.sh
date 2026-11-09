# Run a command in a throwaway pod in orders that looks like an order-worker pod (pause first: kubectl run -i can miss early output).
from_orders() { kubectl --context main -n orders run "chk-$RANDOM$RANDOM" --image="$IMG_CURL" --restart=Never --rm -i --quiet \
  --labels=app=order-worker --command -- sh -c "sleep 1; $1" 2>/dev/null; }
code_from_orders() { from_orders "curl -s -m 4 -o /dev/null -w %{http_code} $1"; }
export -f from_orders code_from_orders
check "order-worker pods reach inventory.stock:8080" bash -c "
  from_orders 'curl -s -m 4 http://inventory.stock:8080' | grep -q 'inventory service' &&
  kubectl --context main -n orders logs deploy/order-worker --since=30s | grep -q 'inventory ok'"
check "other pods stay blocked (warehouse in stock, audit-sink in audit)" bash -c "
  w=\$(kubectl --context main -n stock get pod -l app=warehouse -o jsonpath='{.items[0].status.podIP}')
  a=\$(kubectl --context main -n audit get pod audit-sink -o jsonpath='{.status.podIP}')
  [ -n \"\$w\" ] && [ -n \"\$a\" ] && [ \"\$(code_from_orders http://\$w:80)\" = 000 ] && [ \"\$(code_from_orders http://\$a:80)\" = 000 ]"
# Every egress rule that opens port 53 must target only the kube-dns pods in kube-system, and there must be one.
check "DNS egress allowed only to kube-dns pods in kube-system on port 53" bash -c "
  kubectl --context main -n orders get netpol -o jsonpath='{range .items[*].spec.egress[*]}{.ports[*].port}|{.to[*].podSelector.matchLabels.k8s-app}|{.to[*].namespaceSelector.matchLabels.kubernetes\.io/metadata\.name}|{.to[*].ipBlock.cidr}|{.to}{\"\n\"}{end}' |
  awk -F'|' '
    \$1==\"\" && \$5==\"\" { bad=1 }                                   # allow-everything rule
    \$1 ~ /(^| )53( |\$)/ { dns=1; if (\$5==\"\" || \$4!=\"\" || \$2 !~ /^(kube-dns ?)+\$/ || \$3 !~ /^(kube-system ?)+\$/) bad=1 }
    END { exit !(dns && !bad) }'"
check "egress-lockdown still exists and still selects all pods" bash -c "[ \"\$(kubectl --context main -n orders get netpol egress-lockdown -o jsonpath='{.spec.podSelector}{.spec.policyTypes}')\" = '{}[\"Egress\"]' ]"
