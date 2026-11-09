# Retried, so a slow API server during setup doesn't leave the question half-built.
for n in ledger ledger-archive tools; do wait_for 120 ns main $n; done
Y="$STATE/drill2-q03-rbac.yaml"
cat > "$Y" <<'YAML'
apiVersion: v1
kind: ServiceAccount
metadata: {name: reporter, namespace: ledger}
---
apiVersion: v1
kind: ServiceAccount
metadata: {name: sync-bot, namespace: tools}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata: {name: configmap-editor}
rules:
- apiGroups: [""]
  resources: ["configmaps"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata: {name: namespace-lister}
rules:
- apiGroups: [""]
  resources: ["namespaces"]
  verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata: {name: platform-config-sync}
roleRef: {apiGroup: rbac.authorization.k8s.io, kind: ClusterRole, name: configmap-editor}
subjects:
- {kind: ServiceAccount, name: sync-bot, namespace: tools}
- {kind: ServiceAccount, name: reporter, namespace: ledger}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata: {name: ledger-namespace-lister}
roleRef: {apiGroup: rbac.authorization.k8s.io, kind: ClusterRole, name: namespace-lister}
subjects:
- {kind: ServiceAccount, name: reporter, namespace: ledger}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata: {name: reporter-view, namespace: ledger}
roleRef: {apiGroup: rbac.authorization.k8s.io, kind: ClusterRole, name: view}
subjects:
- {kind: ServiceAccount, name: reporter, namespace: ledger}
YAML
wait_for 120 kubectl --context main apply -f "$Y"
rm -f "$Y"
