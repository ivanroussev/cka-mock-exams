apply alt <<'YAML'
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata: {name: deployment-scaler, namespace: release}
rules:
- apiGroups: [apps]
  resources: [deployments]
  verbs: [get, list, watch]
- apiGroups: [apps]
  resources: [deployments/scale]
  verbs: [get, update, patch]
YAML
kubectl --context alt -n release create rolebinding deploy-bot-scaler --role=deployment-scaler --serviceaccount=release:deploy-bot
