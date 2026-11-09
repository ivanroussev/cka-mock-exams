kubectl --context main -n crunch get pod importer -o jsonpath='{.status.containerStatuses[0].lastState.terminated.reason}' > "$ANSWERS/importer-reason.txt"
kubectl --context main -n crunch get pod importer -o jsonpath='{.status.containerStatuses[0].lastState.terminated.exitCode}' > "$ANSWERS/importer-exitcode.txt"
kubectl --context main -n crunch patch pod cruncher --subresource resize \
  -p '{"spec":{"containers":[{"name":"worker","resources":{"requests":{"cpu":"250m"},"limits":{"cpu":"500m"}}}]}}' >/dev/null
wait_for 60 bash -c "[ \"\$(kubectl --context main -n crunch get pod cruncher -o jsonpath='{.status.containerStatuses[0].resources.limits.cpu}')\" = 500m ]"
