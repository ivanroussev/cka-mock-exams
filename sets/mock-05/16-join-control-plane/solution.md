Docs page: **"Creating Highly Available Clusters with kubeadm"**.

```bash
# On cp1
kubeadm init phase upload-certs --upload-certs                      # prints a new certificate key
kubeadm token create --print-join-command --certificate-key <key>   # full control-plane join command

# On cp2 — paste it (it ends in: --control-plane --certificate-key <key>)
kubeadm join lb:6443 --token … --discovery-token-ca-cert-hash sha256:… --control-plane --certificate-key <key>

# On cp1
kubectl get nodes                       # cp2 control-plane, Ready
kubectl label node cp2 tier=control
```

**Pitfalls:** the `kubeadm-certs` Secret (and so the certificate key) expires 2 hours after `init` / `upload-certs`.
A plain worker join command (without `--control-plane --certificate-key`) makes `cp2` a worker — check the ROLES column.
