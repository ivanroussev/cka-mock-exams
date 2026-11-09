```bash
kubectl config use-context alt
kubectl get nodes                                # cka-alt-worker NotReady
ssh cka-alt-worker                               # here: ./cka ssh cka-alt-worker
systemctl status kubelet                         # activating (auto-restart) — it keeps crashing
journalctl -u kubelet -n 30 --no-pager | grep -iE 'error|fail'
#   → unable to load client CA file /etc/kubernetes/pki/ca.cert: open …: no such file or directory
ls /etc/kubernetes/pki/                          # the file is ca.crt
vim /var/lib/kubelet/config.yaml                 # authentication.x509.clientCAFile: /etc/kubernetes/pki/ca.crt
systemctl restart kubelet
systemctl status kubelet
```
**Where kubelet settings live:** the unit + drop-ins (`systemctl cat kubelet`) give the flags, `--config` points to
`/var/lib/kubelet/config.yaml` (the KubeletConfiguration), and `/var/lib/kubelet/kubeadm-flags.env` adds kubeadm's flags.
`journalctl -u kubelet` tells you which of them is wrong. Changing a config file needs only a restart, not `daemon-reload`.
