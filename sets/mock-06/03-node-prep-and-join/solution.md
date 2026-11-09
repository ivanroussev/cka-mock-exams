```bash
ssh cka-main-worker2
cat <<'EOF2' > /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF2
modprobe overlay; modprobe br_netfilter          # (not possible inside the kind container — fine here)
cat <<'EOF2' > /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-iptables = 1
EOF2
sysctl --system
exit

ssh cka-main-control-plane
kubeadm token create --ttl 2h --print-join-command > /root/join-worker.sh
kubeadm token list                                # TTL ~1h59m
exit

kubectl -n kube-system get cm kubeadm-config -o yaml | grep -E 'serviceSubnet|podSubnet'
echo 10.96.0.0/16 > {{ANSWERS}}/service-cidr.txt
```
Docs: *Container Runtimes → Install and configure prerequisites* and *kubeadm token*.
**Pitfalls:** `sysctl -w` alone is lost at reboot, and a file in `/etc/sysctl.d/` alone isn't active until `sysctl --system`.
`kubeadm token create` defaults to a 24 h TTL. `--print-join-command` builds the whole command, including
`--discovery-token-ca-cert-hash` — no need to compute the hash with openssl by hand.
