A new worker is about to be added to cluster `main` with kubeadm. Prepare what's needed:

1. On `cka-main-worker2` (used as the template for the new machine), make the kernel prerequisites for a kubeadm node **persistent**:
   - the kernel modules `overlay` and `br_netfilter` are loaded at boot (file `/etc/modules-load.d/k8s.conf`, one module per line);
   - the sysctls `net.ipv4.ip_forward = 1` and `net.bridge.bridge-nf-call-iptables = 1` are set at boot (file `/etc/sysctl.d/k8s.conf`),
     and apply them now without rebooting.
2. On `cka-main-control-plane`, create a **new** bootstrap token that is valid for **2 hours** and write the complete `kubeadm join`
   command for a worker that uses it to `/root/join-worker.sh` on that node.
3. Write the cluster's Service CIDR, as configured in kubeadm's cluster configuration, to `{{ANSWERS}}/service-cidr.txt`.
