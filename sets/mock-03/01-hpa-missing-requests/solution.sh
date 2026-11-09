# Retry API calls: on a busy laptop the API server sometimes times out the TLS handshake.
retry() { wait_for 180 "$@"; }
apply() { local f; f=$(mktemp); cat > "$f"; retry kubectl --context "$1" apply -f "$f"; local r=$?; rm -f "$f"; return $r; }
retry kubectl --context main -n pricing set resources deploy/quote-engine --requests=cpu=100m,memory=64Mi --limits=cpu=250m,memory=128Mi
kubectl --context main -n pricing rollout status deploy/quote-engine --timeout=120s
retry kubectl --context main -n pricing patch hpa quote-engine --type=merge -p '{"spec":{"minReplicas":2,"maxReplicas":6,"metrics":[{"type":"Resource","resource":{"name":"cpu","target":{"type":"Utilization","averageUtilization":65}}}],"behavior":{"scaleDown":{"stabilizationWindowSeconds":120}}}}'
wait_for 240 bash -c "[ -n \"\$(kubectl --context main -n pricing get hpa quote-engine -o jsonpath='{.status.currentMetrics[0].resource.current.averageUtilization}')\" ] && [ \"\$(kubectl --context main -n pricing get hpa quote-engine -o jsonpath='{.status.conditions[?(@.type==\"ScalingActive\")].status}')\" = True ]"
