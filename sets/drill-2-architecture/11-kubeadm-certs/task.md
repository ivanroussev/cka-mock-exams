Cluster `alt` was built with kubeadm. Work on node `cka-alt-control-plane`.

1. Write the expiry date of the cluster's root certificate authority `ca`, exactly as `kubeadm` reports it
   (for example `Jan 02, 2036 15:04 UTC`), to `{{ANSWERS}}/ca-expiry.txt`.
2. Using kubeadm, renew **only** the API server's serving certificate (`apiserver`). No other certificate may be renewed.
3. Make sure the running API server actually serves the renewed certificate.
