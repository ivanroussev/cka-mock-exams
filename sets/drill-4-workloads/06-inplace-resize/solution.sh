kubectl --context main -n resize patch pod analytics --subresource resize -p \
  '{"spec":{"containers":[{"name":"analytics","resources":{"requests":{"cpu":"300m"},"limits":{"cpu":"500m","memory":"256Mi"}}}]}}'
wait_for 120 bash -c '[ "$(kubectl --context main -n resize get pod analytics -o jsonpath="{.status.containerStatuses[0].resources.limits.cpu}/{.status.containerStatuses[0].resources.limits.memory}/{.status.containerStatuses[0].ready}")" = 500m/256Mi/true ]'
kubectl --context main -n resize get pod analytics -o jsonpath='{.status.containerStatuses[0].restartCount}' > "$ANSWERS/analytics-restarts.txt"
