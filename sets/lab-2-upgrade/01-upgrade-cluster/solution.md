Follow the official page **"Upgrading kubeadm clusters"** (kubernetes.io → Tasks → Administer a Cluster → Administration with kubeadm). It's allowed during the exam.

**Control plane (`ssh cp1`):**
```bash
# 1. Point apt at the 1.37 repo (pkgs.k8s.io has one repo per minor version)
sed -i 's#/v1.36/#/v1.37/#' /etc/apt/sources.list.d/kubernetes.list
# (only if apt-get update says NO_PUBKEY: re-download the key, as on the docs page)
# curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.37/deb/Release.key | gpg --dearmor --yes -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
apt-get update
apt-cache madison kubeadm               # pick the newest 1.37.x-*
# 2. kubeadm first
apt-mark unhold kubeadm && apt-get install -y kubeadm='1.37.x-*' && apt-mark hold kubeadm
kubeadm upgrade plan
kubeadm upgrade apply v1.37.x
# 3. Drain, upgrade kubelet + kubectl, restart, uncordon
kubectl drain cp1 --ignore-daemonsets
apt-mark unhold kubelet kubectl && apt-get install -y kubelet='1.37.x-*' kubectl='1.37.x-*' && apt-mark hold kubelet kubectl
systemctl daemon-reload && systemctl restart kubelet
kubectl uncordon cp1
```
**Worker (`ssh w1`):** the same, except `kubeadm upgrade node` instead of `upgrade apply`. Run the `drain` / `uncordon` from cp1.

**Easy points to lose:** forgetting to switch the repo (apt only shows 1.36), forgetting `uncordon`, and upgrading kubelet before kubeadm.
