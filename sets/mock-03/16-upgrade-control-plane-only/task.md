The kubeadm cluster on the VMs `cp1` (control plane) and `w1` (worker) runs Kubernetes **v1.36**.
A maintenance window allows upgrading the **control plane only**.

- Upgrade the control-plane node `cp1` — its control-plane components, `kubeadm`, `kubelet` and `kubectl` — to the latest
  **v1.37** patch release available from `pkgs.k8s.io`.
- Do **not** upgrade `w1`: it must keep running kubelet v1.36.
- When you are done, `cp1` must be `Ready` and schedulable again.

Work on `cp1` with `./cka ssh cp1`.
