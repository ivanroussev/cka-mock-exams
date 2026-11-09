# Retry API calls: on a busy laptop the API server sometimes times out the TLS handshake.
retry() { wait_for 180 "$@"; }
apply() { local f; f=$(mktemp); cat > "$f"; retry kubectl --context "$1" apply -f "$f"; local r=$?; rm -f "$f"; return $r; }
echo system:serviceaccount:reports:reporter > "$ANSWERS/report-identity.txt"
retry bash -c 'kubectl --context main -n reports create role pod-reader --verb=list --resource=pods --dry-run=client -o yaml | kubectl --context main apply -f -'
retry bash -c 'kubectl --context main -n reports create rolebinding pod-reader --role=pod-reader --serviceaccount=reports:reporter --dry-run=client -o yaml | kubectl --context main apply -f -'
# Retry the manual run if it fails for an unrelated reason (e.g. a slow API server on a busy laptop).
for i in 1 2 3; do
  kubectl --context main -n reports delete job pod-report-manual --ignore-not-found --wait=true
  retry kubectl --context main -n reports create job pod-report-manual --from=cronjob/pod-report
  kubectl --context main -n reports wait --for=condition=Complete job/pod-report-manual --timeout=120s && break
  kubectl --context main -n reports logs job/pod-report-manual
done
