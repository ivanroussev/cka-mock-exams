```bash
ssh cka-alt-worker
systemctl status kubelet                         # activating (auto-restart)
journalctl -u kubelet --no-pager | tail -5
#   "validate service connection: … dial unix /var/run/crio/crio.sock: connect: no such file or directory"
grep -rn -i runtime /var/lib/kubelet/config.yaml /var/lib/kubelet/kubeadm-flags.env
sed -i 's#unix:///var/run/crio/crio.sock#unix:///run/containerd/containerd.sock#' /var/lib/kubelet/config.yaml
systemctl restart kubelet
journalctl -u kubelet --no-pager | tail -5       # now: containerd.sock … connection refused
crictl ps                                        # same error → the runtime itself is down
systemctl status containerd                      # inactive (dead), disabled
systemctl enable --now containerd
systemctl restart kubelet
exit
kubectl get nodes; kubectl -n kube-system get pods -o wide | grep cka-alt-worker
```
**CRI basics:** the kubelet talks to the runtime only through the CRI socket (`containerRuntimeEndpoint` in the kubelet config,
the old flag was `--container-runtime-endpoint`). containerd's is `unix:///run/containerd/containerd.sock`, CRI-O's
`unix:///var/run/crio/crio.sock`. `crictl` uses the same socket, configured in `/etc/crictl.yaml`.
**Pitfall:** `systemctl start` without `enable` passes the check today and fails after the next reboot.
