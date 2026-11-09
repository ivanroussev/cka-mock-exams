Use **kubeadm** on the control-plane node `cka-alt-control-plane` (`ssh cka-alt-control-plane`):

1. Save kubeadm's overview of when the cluster's certificates and CAs expire to `/root/cert-expiry.txt` **on that node**.
2. A security audit requires new certificates for the API server's serving certificate and for its client certificate towards the kubelets.
   Renew **only these two** certificates.
3. Make sure the running API server is actually using the renewed serving certificate.
