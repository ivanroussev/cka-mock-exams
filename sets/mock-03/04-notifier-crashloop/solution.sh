# Retry API calls: on a busy laptop the API server sometimes times out the TLS handshake.
retry() { wait_for 180 "$@"; }
apply() { local f; f=$(mktemp); cat > "$f"; retry kubectl --context "$1" apply -f "$f"; local r=$?; rm -f "$f"; return $r; }
kubectl --context main -n alerts logs deploy/notifier --previous 2>/dev/null | grep FATAL > "$ANSWERS/notifier-fatal.txt" \
  || kubectl --context main -n alerts logs deploy/notifier | grep FATAL > "$ANSWERS/notifier-fatal.txt"
retry kubectl --context main -n alerts patch deploy notifier --type=json -p='[
  {"op":"replace","path":"/spec/template/spec/containers/0/env/1/valueFrom/secretKeyRef","value":{"name":"smtp-credentials","key":"password"}},
  {"op":"add","path":"/spec/template/spec/containers/0/envFrom","value":[{"configMapRef":{"name":"notifier-config"}}]}]'
kubectl --context main -n alerts rollout status deploy/notifier --timeout=120s
wait_for 30 bash -c "kubectl --context main -n alerts logs deploy/notifier | grep -q connected"
