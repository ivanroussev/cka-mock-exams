The VMs `cp1` and `w1` are fresh Ubuntu 24.04 machines. Prepare **both** of them to run Kubernetes **v1.37** with `kubeadm`.
Questions 2 and 3 build on this one.

On `cp1` **and** `w1`:

1. Load the kernel modules `overlay` and `br_netfilter`, and make sure they are loaded again after a reboot.
2. Set these kernel parameters to `1` and persist them in a file under `/etc/sysctl.d/`:
   `net.bridge.bridge-nf-call-iptables`, `net.bridge.bridge-nf-call-ip6tables`, `net.ipv4.ip_forward`.
3. Turn swap off, and keep it off after a reboot.
4. Install the container runtime `containerd` (the Ubuntu package is fine) and configure it to use the **systemd cgroup driver**.
5. Install `kubeadm`, `kubelet` and `kubectl` **v1.37** from the Kubernetes package repository `pkgs.k8s.io`,
   and stop `apt` from upgrading them.

Reach the nodes with `./cka ssh cp1` and `./cka ssh w1` (you are root).
