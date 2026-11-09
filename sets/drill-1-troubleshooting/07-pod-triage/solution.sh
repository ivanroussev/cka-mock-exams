echo ledger > "$ANSWERS/triage-oom.txt"
echo catalog > "$ANSWERS/triage-image.txt"
kubectl --context main -n triage patch deploy gateway --type=json -p='[
  {"op":"replace","path":"/spec/template/spec/containers/0/readinessProbe/httpGet/path","value":"/"},
  {"op":"replace","path":"/spec/template/spec/containers/0/livenessProbe/httpGet/path","value":"/"}]'
kubectl --context main -n triage rollout status deploy/gateway --timeout=120s
