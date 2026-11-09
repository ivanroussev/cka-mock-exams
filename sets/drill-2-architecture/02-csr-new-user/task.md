A new auditor, `mira`, needs access to cluster `main` with a client certificate signed by the cluster CA.

1. Create a private key and a certificate signing request for user `mira` (CN `mira`, organisation `auditors`).
   Save the key as `{{ANSWERS}}/mira.key`.
2. Submit it as a Kubernetes CertificateSigningRequest named `mira` (signer `kubernetes.io/kube-apiserver-client`,
   usage `client auth`, valid for one day) and approve it.
3. Save the issued certificate to `{{ANSWERS}}/mira.crt`.
4. Add a user `mira` to your kubeconfig with the key and certificate **embedded**, and a context named `mira@main`
   that uses the same cluster as context `main`.
5. In namespace `audit`, create a Role `log-reader` that allows `get` and `list` on pods and their logs,
   and bind it to user `mira` with a RoleBinding named `mira-log-reader`.
