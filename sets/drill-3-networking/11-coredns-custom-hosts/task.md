Context: `alt`

Applications in cluster `alt` need two legacy hostnames that no upstream DNS server knows:

| Name                  | IP            |
|-----------------------|---------------|
| `vault.corp.internal` | `172.20.50.10` |
| `ldap.corp.internal`  | `172.20.50.11` |

Configure the cluster's CoreDNS so that **every Pod** resolves these names to these IPs. Cluster-internal names
(e.g. `kubernetes.default.svc.cluster.local`) must keep resolving. Change the CoreDNS configuration itself — not individual Pods.
