```bash
# On cp1
kubectl cordon cp1
systemctl stop kubelet                # first, or it restarts the static pods
crictl stop $(crictl ps -q)
crictl ps                             # empty

# On cp2 (admin.conf / ~/.kube/config already point at https://lb:6443)
kubectl get nodes                     # works: HAProxy sends requests to cp2/cp3; cp1 turns NotReady after ~40 s
kubectl -n kube-system get lease kube-scheduler kube-controller-manager
#   HOLDER is "<node>_<random id>" — wait until it is not cp1 (lease duration 15 s)
vim /root/leaders.txt
#   kube-scheduler: cp2
#   kube-controller-manager: cp3
```

**Why it keeps working:** each control-plane node runs its own API server behind `lb:6443`, etcd keeps quorum with
2 of 3 members, and the scheduler and controller manager run active/standby — a standby instance takes over the lease
when the leader stops renewing it. With 3 etcd members you can lose **one** node; losing two loses quorum and the API
stops answering writes.
