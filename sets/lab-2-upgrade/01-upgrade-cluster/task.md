The cluster on nodes `cp1` (control plane) and `w1` (worker) runs Kubernetes **v1.36**.

Upgrade **both** nodes to the latest **v1.37** patch release available from the Kubernetes package repository (`pkgs.k8s.io`).

- Upgrade the control plane first, then the worker.
- Drain each node before upgrading kubelet, and make it schedulable again afterwards.
- Upgrade `kubeadm`, `kubelet` and `kubectl` on both nodes.

Run `kubectl` from `cp1` (`./cka ssh cp1`).
