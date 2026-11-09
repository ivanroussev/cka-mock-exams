No ReplicaSet, no pods, no events: nothing is reconciling Deployments → the **controller-manager** is down
(a broken scheduler would give you *Pending* pods instead).
```bash
kubectl config use-context alt
kubectl -n ops get deploy,rs,pods                 # deploy 0/2, no ReplicaSet
kubectl -n kube-system get pods                   # kube-controller-manager-… CrashLoopBackOff
kubectl -n kube-system logs kube-controller-manager-cka-alt-control-plane
#   → stat /etc/kubernetes/controller-manager.cnf: no such file or directory
ssh cka-alt-control-plane
vim /etc/kubernetes/manifests/kube-controller-manager.yaml   # --kubeconfig=/etc/kubernetes/controller-manager.conf
# the kubelet restarts the static pod by itself; watch with:
crictl ps | grep controller
kubectl -n ops get pods -w
```
**Pattern:** compare the flag with the `volumeMounts`/`volumes` in the same manifest — only files that are mounted exist
inside the container. If `kubectl` logs don't work, use `crictl ps -a` and `crictl logs <id>` on the control-plane node.
