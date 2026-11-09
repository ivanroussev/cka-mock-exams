Namespace `ledger` runs two apps: pods labelled `app=ledger-api` and pods labelled `app=ledger-db` (the db answers HTTP on port 80, Service `ledger-db`).
Lock the namespace down with NetworkPolicies:

1. `default-deny`: denies **all ingress and all egress** traffic for every pod in `ledger`.
2. `api-egress`: allows pods `app=ledger-api` to connect to pods `app=ledger-db` on TCP port 80, **and** to resolve
   DNS names through the cluster DNS (pods `k8s-app=kube-dns` in namespace `kube-system`, port 53 UDP and TCP).
3. `db-ingress`: allows pods `app=ledger-db` to receive traffic on TCP port 80 from pods `app=ledger-api` only.

From an `app=ledger-api` pod, `http://ledger-db` must work; everything else must be blocked.
