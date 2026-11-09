kubectl --context main -n probes patch deploy ledger-ui --type=strategic -p '{"spec":{"template":{"spec":{"containers":[{"name":"web",
  "startupProbe":{"httpGet":{"path":"/","port":80},"periodSeconds":5,"failureThreshold":15},
  "readinessProbe":{"httpGet":{"path":"/","port":80},"periodSeconds":5}}]}}}}'
kubectl --context main -n probes rollout status deploy/ledger-ui --timeout=420s
wait_for 90 bash -c '[ "$(kubectl --context main -n probes get pods -l app=ledger-ui --no-headers | wc -l | tr -d " ")" = 2 ]'
