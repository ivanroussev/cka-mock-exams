The release pipeline of the payments team runs as ServiceAccount `release-bot` in namespace `payments` (create it).
Give it exactly these permissions:

1. In namespace `payments` — Role `release-bot`, RoleBinding `release-bot`:
   - Deployments: `get`, `list`, `watch`, `create`, `update`, `patch` (but **not** `delete`),
   - Pods: `get`, `list`, and reading pod **logs**.
2. Cluster-wide — ClusterRole `node-reader`, ClusterRoleBinding `release-bot-node-reader`:
   - Nodes: `get`, `list`.

It must not get any other permissions (for example on Secrets, or on Deployments in other namespaces).
