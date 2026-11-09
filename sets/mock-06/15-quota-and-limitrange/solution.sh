apply main <<'YAML'
apiVersion: v1
kind: LimitRange
metadata: {name: team-red-defaults, namespace: team-red}
spec:
  limits:
  - type: Container
    defaultRequest: {cpu: 100m, memory: 128Mi}
    default: {memory: 256Mi}
    max: {memory: 512Mi}
YAML
# nudge the ReplicaSet controller instead of waiting out its back-off
kubectl --context main -n team-red rollout restart deploy/worker >/dev/null
kubectl --context main -n team-red rollout status deploy/worker --timeout=180s >/dev/null
wait_for 300 deploy_ready main worker team-red 4
# wait until the quota's usage has settled (exactly the 4 running pods)
wait_for 60 bash -c "[ \"\$(kubectl --context main -n team-red get resourcequota team-red-quota -o jsonpath='{.status.used.pods} {.status.used.requests\.memory}')\" = '4 512Mi' ]"
kubectl --context main -n team-red get resourcequota team-red-quota -o jsonpath='{.status.used.requests\.memory}' > "$ANSWERS/quota-used.txt"
