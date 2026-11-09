A cluster was initialised on `cp1` with the control-plane endpoint `lb:6443` (HAProxy on the VM `lb` balances
`cp1`, `cp2` and `cp3`). `w1` has joined as a worker. `cp2` and `cp3` are prepared (containerd, kubeadm, kubelet, kubectl v1.37)
but not part of the cluster yet. The certificate key printed by `kubeadm init` was not saved.

1. Join `cp2` and `cp3` as additional **control-plane** nodes through the endpoint `lb:6443`, so that each runs its own
   API server, controller manager, scheduler and stacked etcd member.
2. Set up `kubectl` for `root` on `cp2` and `cp3` with the default kubeconfig location (`/root/.kube/config`).

All three control-plane nodes must be `Ready`. Question 2 builds on this one.
