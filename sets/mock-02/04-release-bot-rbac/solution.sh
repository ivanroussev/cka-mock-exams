kubectl --context main -n payments create serviceaccount release-bot
apply main <<'YAML'
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata: {name: release-bot, namespace: payments}
rules:
- apiGroups: [apps]
  resources: [deployments]
  verbs: [get, list, watch, create, update, patch]
- apiGroups: [""]
  resources: [pods, pods/log]
  verbs: [get, list]
YAML
kubectl --context main -n payments create rolebinding release-bot --role=release-bot --serviceaccount=payments:release-bot
kubectl --context main create clusterrole node-reader --verb=get,list --resource=nodes
kubectl --context main create clusterrolebinding release-bot-node-reader --clusterrole=node-reader --serviceaccount=payments:release-bot
