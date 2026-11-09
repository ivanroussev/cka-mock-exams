Docs page: **"Certificate Management with kubeadm"**.

```bash
# On cp1
kubeadm certs check-expiration                       # apiserver shows ~18d RESIDUAL TIME
kubeadm certs check-expiration | grep '^apiserver '  # copy the EXPIRES column
echo 'Nov 28, 2026 15:59 UTC' > /root/apiserver-expiry.txt

kubeadm certs renew apiserver

# Restart the API server so it picks up the new certificate: it's a static pod,
# so move the manifest away until the pod is gone, then move it back.
mv /etc/kubernetes/manifests/kube-apiserver.yaml /tmp/ ; sleep 20
mv /tmp/kube-apiserver.yaml /etc/kubernetes/manifests/
kubectl get --raw /readyz

# Verify what is served
echo | openssl s_client -connect 127.0.0.1:6443 2>/dev/null | openssl x509 -noout -enddate
```

**Notes:** `kubeadm certs renew all` would also work but renews more than asked (and then the controller-manager,
scheduler and etcd need restarting too, and `admin.conf` changes — copy it to `~/.kube/config` again).
`kubectl delete pod kube-apiserver-cp1 -n kube-system` only deletes the *mirror* pod; it does not restart the container.
`kubeadm upgrade apply` renews all certificates automatically — clusters that are upgraded at least once a year never expire.
