```bash
kubectl config use-context alt
kubectl get nodes                          # cka-alt-worker NotReady
ssh cka-alt-worker                         # here: ./cka ssh cka-alt-worker
systemctl status kubelet                   # activating (auto-restart), status=203/EXEC
journalctl -u kubelet -n 20 --no-pager     # "Failed to locate executable /usr/local/bin/kubelet"
which kubelet                              # /usr/bin/kubelet
systemctl cat kubelet                      # shows which file sets ExecStart → 10-kubeadm.conf drop-in
vim /etc/systemd/system/kubelet.service.d/10-kubeadm.conf   # ExecStart=/usr/bin/kubelet …
systemctl daemon-reload                    # needed after editing a unit file!
systemctl restart kubelet
systemctl is-enabled kubelet
```
**Pitfall:** after editing a unit or drop-in, `systemctl restart` alone keeps using the old definition — run
`systemctl daemon-reload` first. Exit code `203/EXEC` always means "the binary in ExecStart can't be executed".
`systemctl cat kubelet` is the quickest way to see the unit *and* all its drop-ins.
