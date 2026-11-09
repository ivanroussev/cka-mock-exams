prep='set -e
export DEBIAN_FRONTEND=noninteractive
printf "overlay\nbr_netfilter\n" > /etc/modules-load.d/k8s.conf
modprobe overlay; modprobe br_netfilter
printf "net.bridge.bridge-nf-call-iptables = 1\nnet.bridge.bridge-nf-call-ip6tables = 1\nnet.ipv4.ip_forward = 1\n" > /etc/sysctl.d/k8s.conf
sysctl --system >/dev/null
swapoff -a; sed -i "/[[:space:]]swap[[:space:]]/ s/^#*/#/" /etc/fstab
apt-get update -q
apt-get install -y -q containerd apt-transport-https ca-certificates curl gpg
mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml
sed -i "s/SystemdCgroup = false/SystemdCgroup = true/" /etc/containerd/config.toml
grep -q SystemdCgroup /etc/containerd/config.toml || sed -i "/runtimes.runc.options\]/a\            SystemdCgroup = true" /etc/containerd/config.toml
systemctl restart containerd; systemctl enable containerd
mkdir -p /etc/apt/keyrings
curl -fsSL --retry 5 --retry-all-errors https://pkgs.k8s.io/core:/stable:/v1.37/deb/Release.key | gpg --dearmor --yes -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.37/deb/ /" > /etc/apt/sources.list.d/kubernetes.list
apt-get update -q
apt-get install -y -q kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl
systemctl enable kubelet'
node_exec cp1 "$prep" & p1=$!
node_exec w1 "$prep" & p2=$!
wait $p1; wait $p2
