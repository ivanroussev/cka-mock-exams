Docs page: **"Creating a cluster with kubeadm"** (Tasks → Administer a Cluster → Administration with kubeadm).

```bash
# On cp1
kubeadm init --pod-network-cidr 10.244.0.0/16
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
kubectl get nodes -w              # cp1 turns Ready once flannel runs

# kubeadm init printed the join command; if you lost it, make a new one:
kubeadm token create --print-join-command

# On w1 — paste the join command
kubeadm join cp1:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>

# Back on cp1
kubectl get nodes                 # both Ready
```

**Pitfalls:** flannel's manifest assumes `10.244.0.0/16` — init with a different `--pod-network-cidr` and flannel pods crash
(or you must edit `net-conf.json`). Without a CNI the nodes stay `NotReady` and CoreDNS stays `Pending`. If `kubeadm init`
fails its preflight checks, the message names what question 1 missed (swap, `ip_forward`, the CRI socket).
If you must start over: `kubeadm reset -f` on the node.
