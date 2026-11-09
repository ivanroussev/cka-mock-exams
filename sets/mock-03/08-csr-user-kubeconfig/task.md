A new release engineer, `mira`, needs access to cluster `main`. She is a member of the group `release-eng`.

1. Create a private key `{{ANSWERS}}/mira.key` and a certificate signing request for user `mira` in organisation (group) `release-eng`.
   Submit it as CertificateSigningRequest `mira` (signer `kubernetes.io/kube-apiserver-client`, valid for **1 day**) and approve it.
2. Save the issued certificate as `{{ANSWERS}}/mira.crt` and create the kubeconfig `{{ANSWERS}}/mira.kubeconfig` with a cluster entry for
   `main`'s API server, user `mira` and a context `mira@main`, which must be the current context. Embed all certificates and keys.
3. In namespace `releases`, create Role `release-manager` that allows `get`, `list`, `watch`, `update` and `patch` on Deployments and
   `get`, `list` on Pods and `pods/log` — nothing more. Bind it to the **group** `release-eng` with RoleBinding `release-manager`.
