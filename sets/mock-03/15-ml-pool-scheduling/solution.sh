# Retry API calls: on a busy laptop the API server sometimes times out the TLS handshake.
retry() { wait_for 180 "$@"; }
apply() { local f; f=$(mktemp); cat > "$f"; retry kubectl --context "$1" apply -f "$f"; local r=$?; rm -f "$f"; return $r; }
apply main <<'YAML'
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata: {name: ml-batch}
value: 50000
preemptionPolicy: Never
globalDefault: false
description: ML training jobs
YAML
retry kubectl --context main -n ml patch deploy trainer --type=json -p='[
  {"op":"remove","path":"/spec/template/spec/nodeSelector"},
  {"op":"replace","path":"/spec/template/spec/tolerations","value":[{"key":"workload","operator":"Equal","value":"ml","effect":"NoSchedule"}]},
  {"op":"add","path":"/spec/template/spec/priorityClassName","value":"ml-batch"},
  {"op":"add","path":"/spec/template/spec/affinity","value":{"nodeAffinity":{"requiredDuringSchedulingIgnoredDuringExecution":{"nodeSelectorTerms":[{"matchExpressions":[{"key":"pool","operator":"In","values":["ml"]}]}]}}}}]'
kubectl --context main -n ml rollout status deploy/trainer --timeout=180s
wait_for 60 bash -c "[ \$(kubectl --context main -n ml get pods -l app=trainer -o name | wc -l) -eq 2 ]"
