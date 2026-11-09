ServiceAccount `reporter` in namespace `ledger` can currently delete ConfigMaps in **every** namespace of the cluster.

1. Find the binding that grants this. Write it as `<Kind>/<name>` (for example `RoleBinding/foo`) to
   `{{ANSWERS}}/reporter-binding.txt`.
2. Restrict it: `reporter` must keep all the permissions of ClusterRole `configmap-editor`, but **only in namespace `ledger`**.
   Use a RoleBinding named `reporter-configmaps` in `ledger` that references the existing ClusterRole.
   Every other subject of the binding you found must keep its current access.
