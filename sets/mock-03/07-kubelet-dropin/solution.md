```bash
kubectl get nodes                          # cka-alt-worker NotReady
ssh cka-alt-worker                         # here: ./cka ssh cka-alt-worker
systemctl status kubelet                   # activating (auto-restart), and "disabled"
journalctl -u kubelet -n 20 --no-pager     # failed to load kubelet config file, path: /etc/kubernetes/kubelet-tuned.yaml
systemctl cat kubelet                      # shows every drop-in in order: 10-kubeadm.conf, 11-kind.conf, 20-tuning.conf
rm /etc/systemd/system/kubelet.service.d/20-tuning.conf    # (or fix the path in it)
systemctl daemon-reload
systemctl enable --now kubelet
systemctl restart kubelet
```
**Why:** drop-ins in `kubelet.service.d/` are applied in name order, so `20-tuning.conf` overrides `KUBELET_CONFIG_ARGS` from
`10-kubeadm.conf`. `systemctl cat` is the quickest way to see the effective unit. Forgetting `daemon-reload` leaves the old unit in place;
forgetting `enable` means the node breaks again on the next reboot.
