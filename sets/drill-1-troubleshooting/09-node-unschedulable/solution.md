```bash
kubectl -n ops describe pod -l app=reports | grep -A3 Events
#  0/3 nodes are available: 1 node(s) didn't match Pod's node affinity/selector, 1 node(s) had untolerated taint
#  {node-role.kubernetes.io/control-plane: }, 1 node(s) were unschedulable …
kubectl get nodes -l disk=ssd                      # cka-main-worker2  Ready,SchedulingDisabled
kubectl describe node cka-main-worker2 | grep -A3 Taints
#  maintenance=planned:NoSchedule  +  node.kubernetes.io/unschedulable:NoSchedule
kubectl uncordon cka-main-worker2
kubectl taint node cka-main-worker2 maintenance-   # trailing "-" removes the taint (key, or key:effect)
kubectl -n ops get pods -o wide
```
**Two independent blockers:** `cordon` (shown as `SchedulingDisabled`) and a custom taint. Uncordoning alone leaves
the pods Pending — always re-read the scheduler event after each fix.
