```bash
ssh cka-alt-control-plane
kubeadm certs check-expiration > /root/cert-expiry.txt
kubeadm certs renew apiserver                    # serving cert (apiserver.crt)
kubeadm certs renew apiserver-kubelet-client     # client cert the API server uses for kubelets
# kubeadm prints: "You must restart the kube-apiserver, kube-controller-manager, kube-scheduler and etcd…"
# Static pods are restarted by moving the manifest away and back (wait ~20s each way), or by stopping the container:
crictl stop $(crictl ps --name kube-apiserver -q)          # kubelet starts it again with the new files
openssl x509 -in /etc/kubernetes/pki/apiserver.crt -noout -dates -serial
```
Docs: *Administer a Cluster → Certificate Management with kubeadm*.
**Pitfalls:** `kubeadm certs renew all` would renew every certificate and kubeconfig — not what was asked.
Components read their certificates only at start-up, so a renewal without a restart changes nothing on the wire.
`kubectl delete pod kube-apiserver-…` only deletes the mirror pod; it doesn't restart the container.
