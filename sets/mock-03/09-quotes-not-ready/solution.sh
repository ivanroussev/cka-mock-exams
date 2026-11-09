# Retry API calls: on a busy laptop the API server sometimes times out the TLS handshake.
retry() { wait_for 180 "$@"; }
apply() { local f; f=$(mktemp); cat > "$f"; retry kubectl --context "$1" apply -f "$f"; local r=$?; rm -f "$f"; return $r; }
retry kubectl --context main -n quotes patch deploy quotes --type=json -p='[{"op":"replace","path":"/spec/template/spec/containers/0/readinessProbe/httpGet/port","value":"http"}]'
retry kubectl --context main -n quotes patch svc quotes --type=json -p='[{"op":"replace","path":"/spec/ports/0/targetPort","value":"http"}]'
kubectl --context main -n quotes rollout status deploy/quotes --timeout=120s
