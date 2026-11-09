Configure the cluster DNS (CoreDNS) of cluster `main`:

1. First save the current Corefile to `{{ANSWERS}}/Corefile.bak`.
2. A legacy application still connects to `db.legacy.internal`. Make that name resolve, for every pod in the cluster, to the Service
   `postgres` in namespace `data` (i.e. the same answer as `postgres.data.svc.cluster.local`).
3. Make `registry.corp.internal` resolve to the static address `10.20.30.40` for every pod in the cluster.

All other DNS resolution must keep working.
