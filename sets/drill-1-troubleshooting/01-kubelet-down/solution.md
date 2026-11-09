```bash
kubectl get nodes                       # cka-alt-worker NotReady
kubectl describe node cka-alt-worker    # "Kubelet stopped posting node status"
ssh cka-alt-worker                      # here: ./cka ssh cka-alt-worker
systemctl status kubelet                # inactive (dead), disabled
systemctl enable --now kubelet          # start it AND enable it for reboots
```
**Why it matters:** `systemctl start` alone fixes it until the next reboot. "Must survive a reboot" means `enable`.
If kubelet is running but the node is still NotReady, check `journalctl -u kubelet -e` next.
