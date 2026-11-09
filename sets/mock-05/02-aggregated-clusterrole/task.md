The monitoring stack's ServiceAccount `prom-reader` (namespace `observability`) needs read access across the cluster, managed through
**ClusterRole aggregation** so other teams can contribute permissions later.

1. Create a ClusterRole `monitoring` whose rules are aggregated from every ClusterRole labelled `rbac.example.com/aggregate-to-monitoring: "true"`.
2. The existing ClusterRole `monitoring-view-nodes` is meant to be part of it but isn't picked up. Fix that.
3. Create a ClusterRole `monitoring-view-endpoints` (`get`, `list`, `watch` on `endpointslices` in API group `discovery.k8s.io`) that is aggregated into `monitoring`.
4. Security review: `prom-reader` must **not** be able to read Secrets or ConfigMaps through `monitoring`. Fix this without deleting any ClusterRole.
5. Bind `monitoring` to `prom-reader` cluster-wide with a ClusterRoleBinding named `prom-reader-monitoring`.
