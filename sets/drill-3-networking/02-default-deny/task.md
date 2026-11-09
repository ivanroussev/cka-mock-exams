Context: `main`

Namespace `vault` runs Deployment `secrets-api` with Service `secrets-api` (port 80). Lock the namespace down:

1. Create a NetworkPolicy named `deny-all` in namespace `vault` that blocks **all ingress and all egress** traffic for **every** Pod in the namespace.
2. Create a second NetworkPolicy named `allow-dns` in namespace `vault` that lets every Pod in the namespace send DNS queries
   (UDP and TCP port 53) to Pods in namespace `kube-system` — and nothing else.

Afterwards, Pods in `vault` must still be able to resolve names, but no Pod (inside or outside `vault`) may reach `secrets-api`.
