ips_match() {
  local want got
  want="$(kubectl --context main -n ledger get pods -l app=ledger-api -o jsonpath='{range .items[*]}{.status.podIP}{"\n"}{end}' | grep . | sort)"
  got="$(tr -d ' \r' < "$ANSWERS/ledger-ips.txt" | grep . | sort)"
  [ -n "$want" ] && [ "$want" = "$got" ]
}
check "ledger-ips.txt lists exactly the ledger-api Pod IPs" ips_match
check "invoicer is Running and Ready" pod_ready main invoicer billing
check "LEDGER_URL uses the Service FQDN" field_has main "pod/invoicer -n billing" '{.spec.containers[0].env[?(@.name=="LEDGER_URL")].value}' "ledger-api.ledger.svc.cluster.local"
check "curl \$LEDGER_URL inside invoicer returns the ledger page" bash -c "kubectl --context main -n billing exec invoicer -- sh -c 'curl -s -m 5 \"\$LEDGER_URL\"' | grep -q 'It works'"
