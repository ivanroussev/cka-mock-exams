```bash
kubectl config use-context alt
kubectl -n sync describe pod -l app=ledger-sync         # Pending, no events → nothing is scheduling
kubectl -n kube-system get pods                         # kube-scheduler-cka-alt-control-plane CrashLoopBackOff
kubectl -n kube-system logs kube-scheduler-cka-alt-control-plane
#   invalid configuration: no configuration has been provided (the kubeconfig it reads is empty)
ssh cka-alt-control-plane
grep -n -A3 kubeconfig /etc/kubernetes/manifests/kube-scheduler.yaml
#   --kubeconfig=/etc/kubernetes/scheduler.conf  … mountPath /etc/kubernetes/scheduler.conf, name: kubeconfig
#   volumes: hostPath path: /etc/kubernetes/scheduler-v2.conf  (type FileOrCreate → kubelet created an EMPTY file)
vim /etc/kubernetes/manifests/kube-scheduler.yaml       # path: /etc/kubernetes/scheduler.conf
echo kubeconfig > {{ANSWERS}}/scheduler-volume.txt
```
**Lesson:** the flags can look perfect while the *volume* behind them is wrong — the container sees whatever the hostPath points at.
`type: FileOrCreate` hides the mistake by creating an empty file instead of failing. Always compare `volumeMounts` with `volumes`.
