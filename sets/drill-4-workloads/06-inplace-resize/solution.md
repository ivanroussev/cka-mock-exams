```bash
kubectl config use-context main
kubectl -n resize get pod analytics -o yaml | grep -A4 resizePolicy     # cpu: NotRequired, memory: RestartContainer
kubectl -n resize patch pod analytics --subresource resize --type=merge -p \
  '{"spec":{"containers":[{"name":"analytics","resources":{"requests":{"cpu":"300m"},"limits":{"cpu":"500m","memory":"256Mi"}}}]}}'
kubectl -n resize get pod analytics -o jsonpath='{.status.containerStatuses[0].resources}{"\n"}{.status.containerStatuses[0].restartCount}{"\n"}'
kubectl -n resize get pod analytics -o jsonpath='{.status.containerStatuses[0].restartCount}' > {{ANSWERS}}/analytics-restarts.txt   # 1
```
Docs: *Resize CPU and Memory Resources assigned to Containers*.

- A normal `kubectl edit`/`patch` of a pod's resources is rejected. Resizing goes through the `resize` subresource (`--subresource resize`).
  `kubectl edit pod analytics --subresource resize` works too.
- `resizePolicy` decides what happens for each resource. CPU is `NotRequired`, so it changes live. Memory is `RestartContainer`, so the
  kubelet restarts **the container** (not the pod: same UID and IP). The restart count goes from 0 to 1.
- `spec.containers[].resources` is what you asked for. `status.containerStatuses[].resources` is what's actually applied. The pod condition
  `PodResizeInProgress` shows up while the kubelet is still working on it, and `PodResizePending` when it can't apply the resize (e.g. the node doesn't have enough room).
