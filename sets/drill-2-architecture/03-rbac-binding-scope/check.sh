R=system:serviceaccount:ledger:reporter
# Accept any capitalisation and the long "clusterrolebinding.rbac.authorization.k8s.io/…" form.
check "binding written to reporter-binding.txt" bash -c "[ \"\$(tr -d '[:space:]' < '$ANSWERS/reporter-binding.txt' | tr 'A-Z' 'a-z' | sed 's#^clusterrolebinding\.rbac\.authorization\.k8s\.io/#clusterrolebinding/#')\" = clusterrolebinding/platform-config-sync ]"
check "reporter can no longer delete ConfigMaps outside ledger" bash -c "cannot_i main 'delete configmaps' $R ledger-archive && cannot_i main 'delete configmaps' $R default"
check "reporter can still create and delete ConfigMaps in ledger" bash -c "can_i main 'delete configmaps' $R ledger && can_i main 'create configmaps' $R ledger"
check "RoleBinding reporter-configmaps binds reporter to ClusterRole configmap-editor" bash -c "
  [ \"\$(kubectl --context main -n ledger get rolebinding reporter-configmaps -o jsonpath='{.roleRef.kind}/{.roleRef.name}')\" = ClusterRole/configmap-editor ] &&
  kubectl --context main -n ledger get rolebinding reporter-configmaps -o jsonpath='{range .subjects[*]}{.kind}/{.namespace}/{.name}{\"\\n\"}{end}' | grep -qx ServiceAccount/ledger/reporter"
check "sync-bot can still edit ConfigMaps cluster-wide" bash -c "can_i main 'delete configmaps' system:serviceaccount:tools:sync-bot default && can_i main 'delete configmaps' system:serviceaccount:tools:sync-bot ledger-archive"
