# Like http_get_as from lib/check.sh, but pauses before curling: `kubectl run -i` can miss output printed before it attaches.
web_as() { # web_as <ns> <labels> <url>  → prints the body; fails if the connection fails
  kubectl --context main -n "$1" run "chk-$RANDOM$RANDOM" --image="$IMG_CURL" --restart=Never --rm -i --quiet \
    --labels="$2" --command -- sh -c "sleep 1; curl -s -m 4 $3" 2>/dev/null
}
reach()   { web_as "$@" | grep -q 'Welcome to nginx'; }
blocked() { ! web_as "$@" >/dev/null; }
export -f web_as reach blocked
U=http://ledger.payments
check "prometheus in monitoring can reach the ledger" reach monitoring "app=prometheus" $U
check "role=api pods in payments can reach the ledger" reach payments "role=api" $U
check "other pods in monitoring are blocked" blocked monitoring "app=grafana" $U
check "app=prometheus pods outside monitoring are blocked" bash -c "blocked payments app=prometheus $U && blocked sandbox app=prometheus $U"
check "default-deny-ingress is unchanged" bash -c "[ \"\$(kubectl --context main -n payments get netpol default-deny-ingress -o jsonpath='{.spec.podSelector}{.spec.policyTypes}{.spec.ingress}')\" = '{}[\"Ingress\"]' ]"
