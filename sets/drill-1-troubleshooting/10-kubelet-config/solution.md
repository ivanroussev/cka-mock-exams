```bash
ssh cka-bare-worker
systemctl status kubelet             # activating (auto-restart), exit-code
journalctl -u kubelet -n 30 --no-pager
#  "failed to load kubelet config file" path="/var/lib/kubelet/kubelet-config.yaml" … no such file or directory
systemctl cat kubelet                # shows the unit AND its drop-ins, with their file paths
ls /var/lib/kubelet/                 # the real file is config.yaml
vim /etc/systemd/system/kubelet.service.d/10-kubeadm.conf   # --config=/var/lib/kubelet/config.yaml
systemctl daemon-reload              # REQUIRED after editing a unit/drop-in
systemctl restart kubelet && systemctl enable kubelet
systemctl status kubelet             # active (running)
```
**Where kubelet settings live (kubeadm):** the drop-in `10-kubeadm.conf` (how it starts), `/var/lib/kubelet/kubeadm-flags.env`
(extra flags), `/var/lib/kubelet/config.yaml` (KubeletConfiguration), `/etc/kubernetes/kubelet.conf` (kubeconfig).
Forgetting `daemon-reload` means systemd keeps using the old unit.
