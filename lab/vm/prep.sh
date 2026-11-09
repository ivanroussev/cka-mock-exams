#!/bin/bash
# Prepare a node for kubeadm: kernel modules, sysctls, containerd, kubeadm/kubelet/kubectl.
# Usage: prep.sh <minor version, e.g. 1.37>
set -eux
VER="$1"
export DEBIAN_FRONTEND=noninteractive
swapoff -a; sed -i '/ swap /d' /etc/fstab
printf 'overlay\nbr_netfilter\n' > /etc/modules-load.d/k8s.conf
modprobe overlay; modprobe br_netfilter
printf 'net.bridge.bridge-nf-call-iptables = 1\nnet.bridge.bridge-nf-call-ip6tables = 1\nnet.ipv4.ip_forward = 1\n' > /etc/sysctl.d/k8s.conf
sysctl --system >/dev/null
apt-get update -q
apt-get install -y -q containerd apt-transport-https ca-certificates curl gpg
mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
# containerd 2.x config layout
grep -q SystemdCgroup /etc/containerd/config.toml || sed -i "/runtimes.runc.options\]/a\            SystemdCgroup = true" /etc/containerd/config.toml
systemctl restart containerd; systemctl enable containerd
mkdir -p /etc/apt/keyrings
curl -fsSL --retry 5 --retry-all-errors "https://pkgs.k8s.io/core:/stable:/v$VER/deb/Release.key" | gpg --dearmor --yes -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v$VER/deb/ /" > /etc/apt/sources.list.d/kubernetes.list
apt-get update -q
apt-get install -y -q kubelet kubeadm kubectl cri-tools
apt-mark hold kubelet kubeadm kubectl
crictl config --set runtime-endpoint=unix:///run/containerd/containerd.sock >/dev/null
systemctl enable kubelet
# etcdctl for backup/restore questions
if ! command -v etcdctl >/dev/null; then
  curl -fsSL --retry 5 --retry-all-errors https://github.com/etcd-io/etcd/releases/download/v3.6.16/etcd-v3.6.16-linux-arm64.tar.gz | tar -xz -C /usr/local/bin --strip-components=1 etcd-v3.6.16-linux-arm64/etcdctl etcd-v3.6.16-linux-arm64/etcdutl
fi
