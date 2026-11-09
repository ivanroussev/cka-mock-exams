# Retry API calls: on a busy laptop the API server sometimes times out the TLS handshake.
retry() { wait_for 180 "$@"; }
save() { local f="$1" i=0; shift; while [ $i -lt 36 ]; do "$@" > "$f" 2>/dev/null && [ -s "$f" ] && return 0; i=$((i+1)); sleep 5; done; return 1; }
apply() { local f; f=$(mktemp); cat > "$f"; retry kubectl --context "$1" apply -f "$f"; local r=$?; rm -f "$f"; return $r; }
retry kubectl --context main -n storefront patch deploy frontend --type=json -p='[
  {"op":"replace","path":"/spec/template/spec/dnsPolicy","value":"ClusterFirst"},
  {"op":"replace","path":"/spec/template/spec/dnsConfig","value":{"searches":["inventory.svc.cluster.local"]}}]'
kubectl --context main -n storefront rollout status deploy/frontend --timeout=120s
save "$ANSWERS/cluster-dns-ip.txt" bash -c 'kubectl --context main -n kube-system get svc kube-dns -o jsonpath='\''{.spec.clusterIP}'\'''
wait_for 60 bash -c "kubectl --context main -n storefront logs deploy/frontend --since=10s | grep -q '1204 products'"
