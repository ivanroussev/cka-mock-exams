The VMs `cp1` and `w1` have containerd and `kubeadm`, `kubelet` and `kubectl` v1.37 installed, but no cluster yet.

1. Initialise a cluster with `kubeadm` on `cp1` using the pod network CIDR `10.244.0.0/16` and the **service** CIDR `10.112.0.0/16`.
2. Install the flannel network plugin:
   `kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml`
3. Join `w1` as a worker node. Both nodes must be `Ready`.
4. Write the complete `kubeadm join` command for workers (with a valid token and the CA certificate hash) to
   `/root/join-command.txt` on `cp1`.
