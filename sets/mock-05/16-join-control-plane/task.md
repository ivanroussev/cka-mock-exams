The kubeadm cluster on the VMs uses the control-plane endpoint `lb:6443` (HAProxy). It has one control-plane node, `cp1`,
and one worker, `w1`. The VM `cp2` has containerd and kubeadm/kubelet/kubectl v1.37 installed.

1. Join `cp2` to the cluster as an additional **control-plane** node through `lb:6443`.
   The certificate key from the original `kubeadm init` is no longer available.
2. Add the label `tier=control` to the node `cp2`.

`cp2` must be `Ready`. Leave `cp3` alone.
