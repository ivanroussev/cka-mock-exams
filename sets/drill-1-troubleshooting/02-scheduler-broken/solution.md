```bash
kubectl -n checkout describe pod -l app=cart   # no events at all → nothing is scheduling
kubectl -n kube-system get pods                # kube-scheduler-… in CrashLoopBackOff / CreateContainerError
kubectl -n kube-system describe pod kube-scheduler-cka-alt-control-plane
#   → exec: "kube-schedulerr": executable file not found
ssh cka-alt-control-plane
vim /etc/kubernetes/manifests/kube-scheduler.yaml   # fix "- kube-schedulerr" → "- kube-scheduler"
# kubelet restarts the static pod by itself within ~30s. Then:
kubectl -n checkout get pods -w
```
**Pattern:** Pending pods with *no* scheduling events = scheduler is down. Control-plane components are static pods: fix the file in `/etc/kubernetes/manifests/`, never `kubectl edit` the mirror pod.
If `kubectl` itself fails, use `crictl ps -a` and `crictl logs <id>` on the node.
