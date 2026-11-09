ns main observability
kubectl --context main -n observability create serviceaccount prom-reader --dry-run=client -o yaml | kubectl --context main apply -f - >/dev/null
apply main <<'YAML'
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: monitoring-view-pods
  labels: {rbac.example.com/aggregate-to-monitoring: "true"}
rules:
- apiGroups: [""]
  resources: [pods, pods/log]
  verbs: [get, list, watch]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: monitoring-view-nodes
  labels: {rbac.example.com/aggregate-to-monitorig: "true"}
rules:
- apiGroups: [""]
  resources: [nodes, nodes/metrics]
  verbs: [get, list, watch]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: monitoring-debug
  labels: {rbac.example.com/aggregate-to-monitoring: "true", team: sre}
rules:
- apiGroups: [""]
  resources: [secrets, configmaps]
  verbs: [get, list]
YAML
