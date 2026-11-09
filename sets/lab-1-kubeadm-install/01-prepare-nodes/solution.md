Everything is on two docs pages you may open in the exam: **"Container Runtimes"** (modules, sysctls, cgroup driver) and
**"Installing kubeadm"** (swap, apt repo, packages). Run this on `cp1` **and** `w1`:

```bash
# 1. Kernel modules — now and at boot
cat <<EOF > /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
modprobe overlay && modprobe br_netfilter

# 2. sysctls — persisted, then applied
cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sysctl --system

# 3. Swap — off now, and comment it out of /etc/fstab
swapoff -a
sed -i '/\sswap\s/ s/^/#/' /etc/fstab

# 4. containerd with the systemd cgroup driver
apt-get update && apt-get install -y containerd
mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml
vim /etc/containerd/config.toml      # under ...runtimes.runc.options set:  SystemdCgroup = true
systemctl restart containerd
containerd config dump | grep SystemdCgroup     # verify

# 5. Kubernetes packages from pkgs.k8s.io (one repo + key per minor version)
apt-get install -y apt-transport-https ca-certificates curl gpg
mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.37/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.37/deb/ /' > /etc/apt/sources.list.d/kubernetes.list
apt-get update && apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl
systemctl enable --now kubelet       # it crash-loops until kubeadm init/join — that's expected
```

**Easy points to lose:** `swapoff -a` alone doesn't survive a reboot (fix `/etc/fstab`); `modprobe` alone doesn't either
(`/etc/modules-load.d/`); the `br_netfilter` sysctls only exist once the module is loaded. The kubelet defaults to the systemd
cgroup driver, so containerd must match — a mismatch shows up later as control-plane pods restarting over and over.
