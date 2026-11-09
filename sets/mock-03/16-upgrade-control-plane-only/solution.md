Same procedure as **"Upgrading kubeadm clusters"** on kubernetes.io, stopping after the control-plane node. A kubelet may be
up to three minor versions older than the API server, so a v1.36 worker under a v1.37 control plane is a supported state.

```bash
# On cp1
sed -i 's#/v1.36/#/v1.37/#' /etc/apt/sources.list.d/kubernetes.list
apt-get update                       # NO_PUBKEY? re-download the v1.37 Release.key as in the docs
apt-cache madison kubeadm            # newest 1.37.x-*

apt-mark unhold kubeadm && apt-get install -y kubeadm='1.37.x-*' && apt-mark hold kubeadm
kubeadm upgrade plan
kubeadm upgrade apply v1.37.x

kubectl drain cp1 --ignore-daemonsets
apt-mark unhold kubelet kubectl && apt-get install -y kubelet='1.37.x-*' kubectl='1.37.x-*' && apt-mark hold kubelet kubectl
systemctl daemon-reload && systemctl restart kubelet
kubectl uncordon cp1

kubectl get nodes                    # cp1 v1.37.x, w1 v1.36.x
```

**Pitfalls:** don't touch `w1` at all — no repo change, no `apt-get upgrade` there (the packages are held anyway).
Forgetting `uncordon` leaves `cp1` with `SchedulingDisabled`. `kubeadm upgrade apply` needs the exact version (`v1.37.x`).
