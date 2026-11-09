```bash
kubectl -n crunch get pod importer                    # CrashLoopBackOff, RESTARTS climbing
kubectl -n crunch describe pod importer | grep -A4 'Last State'
#   Last State: Terminated  Reason: OOMKilled  Exit Code: 137
kubectl -n crunch get pod importer -o jsonpath='{.status.containerStatuses[0].lastState.terminated.reason}' > {{ANSWERS}}/importer-reason.txt
echo 137 > {{ANSWERS}}/importer-exitcode.txt          # 128 + 9 (SIGKILL from the OOM killer)

kubectl -n crunch top pod cruncher                    # ~100m = its limit
kubectl -n crunch get pod cruncher -o jsonpath='{.spec.containers[0].resizePolicy}'   # cpu: NotRequired → no restart
kubectl -n crunch patch pod cruncher --subresource resize \
  -p '{"spec":{"containers":[{"name":"worker","resources":{"requests":{"cpu":"250m"},"limits":{"cpu":"500m"}}}]}}'
kubectl -n crunch get pod cruncher -o jsonpath='{.status.containerStatuses[0].resources}'   # what the kubelet actually applied
kubectl -n crunch top pod cruncher                    # climbs towards 500m, RESTARTS still 0
```
Docs: *Configure a Pod → Resize CPU and Memory Resources assigned to Containers*.
**Pitfalls:** `kubectl edit pod` / a plain `patch` on `resources` is rejected — resources are only mutable through the `resize`
subresource. `kubectl logs importer` shows nothing useful: an OOM kill comes from the kernel, so look at the container *status*.
