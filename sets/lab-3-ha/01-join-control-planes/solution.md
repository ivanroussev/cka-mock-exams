Docs page: **"Creating Highly Available Clusters with kubeadm"** (stacked etcd topology).

```bash
# On cp1 — re-upload the control-plane certificates and get a new certificate key
kubeadm init phase upload-certs --upload-certs        # last line = the key (valid for 2 hours)
kubeadm token create --print-join-command             # worker join command; add the control-plane flags to it

# On cp2, then (after it is Ready) on cp3
kubeadm join lb:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash> \
  --control-plane --certificate-key <key>
mkdir -p ~/.kube && cp /etc/kubernetes/admin.conf ~/.kube/config

# Verify
kubectl get nodes                                     # cp1, cp2, cp3 control-plane, Ready
kubectl -n kube-system get pods -o wide | grep -E 'etcd|apiserver'
etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key member list -w table
```

**Pitfalls:** `--certificate-key` downloads the CA and service-account keys from the `kubeadm-certs` Secret, which is deleted
after 2 hours — hence `upload-certs` again. Without `--control-plane` the node joins as a worker. Join control planes one at
a time; two simultaneous etcd joins can break quorum. A shortcut: `kubeadm token create --print-join-command --certificate-key <key>`
prints the full control-plane join line.
