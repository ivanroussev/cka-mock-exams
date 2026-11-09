```bash
kubectl config use-context alt
kubectl -n billing-ops get deploy,rs,pods       # replicas 2, but no ReplicaSet scaled up, no pods, no events
kubectl -n kube-system get pods                 # kube-controller-manager-cka-alt-control-plane  CrashLoopBackOff
kubectl -n kube-system logs kube-controller-manager-cka-alt-control-plane
#   stat /etc/kubernetes/controller-manager.kubeconfig: no such file or directory
ssh cka-alt-control-plane
ls /etc/kubernetes/                             # the real file is controller-manager.conf
vim /etc/kubernetes/manifests/kube-controller-manager.yaml   # --kubeconfig=/etc/kubernetes/controller-manager.conf
crictl ps | grep controller-manager             # back after ~20 s
echo kube-controller-manager.yaml > {{ANSWERS}}/broken-manifest.txt
```
**Pattern:** the Deployment → ReplicaSet → Pod chain is driven by controllers in kube-controller-manager. Spec changes are stored
(the API server works) but nothing *acts* on them: no ReplicaSet updates, no events. Compare with a broken scheduler, where pods exist but stay `Pending`.
