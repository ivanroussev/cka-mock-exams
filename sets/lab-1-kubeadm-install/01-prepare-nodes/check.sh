# Every check must hold on both nodes.
both() { node_exec cp1 "$1" && node_exec w1 "$1"; }

check "overlay and br_netfilter loaded and persisted (cp1, w1)" both \
  "lsmod | grep -qw overlay && lsmod | grep -qw br_netfilter &&
   grep -rhsE '^[[:space:]]*overlay[[:space:]]*\$' /etc/modules-load.d/ /etc/modules | grep -q . &&
   grep -rhsE '^[[:space:]]*br_netfilter[[:space:]]*\$' /etc/modules-load.d/ /etc/modules | grep -q ."
check "the 3 sysctls are 1 and persisted in /etc/sysctl.d (cp1, w1)" both \
  "for k in net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward; do
     [ \"\$(sysctl -n \$k 2>/dev/null)\" = 1 ] || exit 1
     grep -rhsE \"^[[:space:]]*\$k[[:space:]]*=[[:space:]]*1\" /etc/sysctl.d/ /etc/sysctl.conf | grep -q . || exit 1
   done"
check "swap is off and not enabled in /etc/fstab (cp1, w1)" both \
  "[ -z \"\$(swapon --show --noheadings)\" ] && ! grep -qE '^[^#]*[[:space:]]swap[[:space:]]' /etc/fstab"
check "containerd is running with the systemd cgroup driver (cp1, w1)" both \
  "systemctl is-active -q containerd && containerd config dump 2>/dev/null | grep -qE 'SystemdCgroup *= *true'"
check "kubeadm, kubelet and kubectl v1.37 installed (cp1, w1)" both \
  "kubeadm version -o short | grep -q '^v1\.37\.' && kubelet --version | grep -q ' v1\.37\.' &&
   kubectl version --client -o json | grep -q '\"minor\": \"37\"'"
check "kubeadm, kubelet and kubectl are held (cp1, w1)" both \
  "[ \"\$(apt-mark showhold | grep -cxE 'kubeadm|kubelet|kubectl')\" = 3 ]"
