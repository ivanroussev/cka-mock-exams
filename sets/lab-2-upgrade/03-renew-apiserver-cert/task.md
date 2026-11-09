The API server certificate of the cluster on `cp1` is close to expiring.

1. On `cp1`, use `kubeadm` to list the certificate expiration dates. Write the expiry date of the **`apiserver`** certificate
   exactly as `kubeadm` shows it in the `EXPIRES` column (e.g. `Mar 14, 2027 09:30 UTC`) to `/root/apiserver-expiry.txt` on `cp1`.
2. Renew **only** the `apiserver` certificate with `kubeadm`.
3. Make sure the running API server serves the renewed certificate.

This question is independent of the other questions — do it before or after them.
