kubectl --context main -n ledger get pods -l app=ledger-api -o jsonpath='{range .items[*]}{.status.podIP}{"\n"}{end}' > "$ANSWERS/ledger-ips.txt"
kubectl --context main -n billing get pod invoicer -o yaml \
  | sed 's#http://ledger-api:80#http://ledger-api.ledger.svc.cluster.local:80#' \
  | kubectl --context main replace --force -f - >/dev/null
wait_for 120 pod_ready main invoicer billing
