`cp1` and `w1` are prepared for Kubernetes v1.37 (question 1). Build a two-node cluster with `kubeadm`:

1. Initialise the control plane on `cp1` with the pod network CIDR `10.244.0.0/16`.
2. Set up `kubectl` for `root` on `cp1` using the default kubeconfig location (`/root/.kube/config`).
3. Install the **flannel** network plugin:
   `kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml`
4. Join `w1` to the cluster as a worker node.

Both nodes must be `Ready`.
