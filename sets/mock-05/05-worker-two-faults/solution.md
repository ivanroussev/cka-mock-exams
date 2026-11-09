Two faults, one hidden behind the other: kubelet first doesn't start at all, then starts but can't talk to the API server.

```bash
kubectl describe node cka-alt-worker        # Ready Unknown: "Kubelet stopped posting node status"
ssh cka-alt-worker                          # here: ./cka ssh cka-alt-worker
systemctl status kubelet                    # activating (auto-restart), exit code 1
journalctl -u kubelet --no-pager | tail     # open /etc/kubernetes/pki/kubelet-ca.crt: no such file or directory
grep -n clientCAFile /var/lib/kubelet/config.yaml
sed -i 's#pki/kubelet-ca.crt#pki/ca.crt#' /var/lib/kubelet/config.yaml
systemctl restart kubelet

systemctl status kubelet                    # active (running) — but the node is still NotReady
journalctl -u kubelet --no-pager | grep -m3 refused    # dial tcp …:6444: connect: connection refused
grep server /etc/kubernetes/kubelet.conf    # …:6444 — the API server listens on 6443
sed -i 's#:6444#:6443#' /etc/kubernetes/kubelet.conf
systemctl restart kubelet && systemctl is-enabled kubelet
```
**Where kubelet's settings live:** the unit + drop-ins (`systemctl cat kubelet`), `/var/lib/kubelet/kubeadm-flags.env`,
the config file `/var/lib/kubelet/config.yaml` and its kubeconfig `/etc/kubernetes/kubelet.conf`.
**Pitfall:** "kubelet is running" is not "node is Ready". After every fix, read the log again.
