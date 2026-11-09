No pods *at all* (not even Pending) means nobody is turning the Deployment into a ReplicaSet and pods: that's the
**controller manager**'s job. (Pending pods with no events would point at the scheduler instead.)

```bash
kubectl -n ops get deploy,rs,pods             # deploy 0/2, no new ReplicaSet/pods
kubectl -n kube-system get pods               # kube-controller-manager-… CrashLoopBackOff
kubectl -n kube-system logs kube-controller-manager-cka-alt-control-plane
#   → stat /etc/kubernetes/controller-manager.kubeconfig: no such file or directory
ssh cka-alt-control-plane
ls /etc/kubernetes/*.conf                     # the real file is controller-manager.conf
vim /etc/kubernetes/manifests/kube-controller-manager.yaml
#   fix --kubeconfig, --authentication-kubeconfig AND --authorization-kubeconfig
# kubelet re-creates the static pod within ~30s
kubectl -n ops get pods -w
```
**Pitfall:** fixing only the first `--kubeconfig` flag isn't enough — the pod still crashes on the next flag. Search the whole file
(`grep -n kubeconfig`). If `kubectl logs` doesn't work, use `crictl ps -a | grep controller` and `crictl logs <id>` on the node.
