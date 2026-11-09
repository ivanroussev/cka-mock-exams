echo "ClusterRoleBinding/platform-config-sync" > "$ANSWERS/reporter-binding.txt"
kc main -n ledger create rolebinding reporter-configmaps --clusterrole=configmap-editor --serviceaccount=ledger:reporter
kc main patch clusterrolebinding platform-config-sync --type=json -p='[{"op":"remove","path":"/subjects/1"}]'
