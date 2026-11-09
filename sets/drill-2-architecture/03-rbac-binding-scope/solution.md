```bash
kubectl config use-context main
kubectl auth can-i delete configmaps -n default --as system:serviceaccount:ledger:reporter   # yes → cluster-wide grant
# Which bindings mention the ServiceAccount? (-o wide shows ROLE and SERVICEACCOUNTS columns)
kubectl get clusterrolebindings -o wide | grep ledger/reporter
#   platform-config-sync     ClusterRole/configmap-editor   ... tools/sync-bot, ledger/reporter   ← this one
#   ledger-namespace-lister  ClusterRole/namespace-lister   ... ledger/reporter                   (namespaces only)
kubectl get rolebindings -A -o wide | grep ledger/reporter
#   ledger  reporter-view    ClusterRole/view                                                     (read-only)
echo ClusterRoleBinding/platform-config-sync > {{ANSWERS}}/reporter-binding.txt

# Same ClusterRole, namespaced grant:
kubectl -n ledger create rolebinding reporter-configmaps --clusterrole=configmap-editor --serviceaccount=ledger:reporter
# Remove only reporter from the cluster-wide binding — don't delete it, sync-bot still needs it:
kubectl edit clusterrolebinding platform-config-sync      # delete the reporter subject

kubectl auth can-i delete configmaps -n default --as system:serviceaccount:ledger:reporter   # no
kubectl auth can-i delete configmaps -n ledger  --as system:serviceaccount:ledger:reporter   # yes
```
**Key idea:** a ClusterRole is only a set of rules — *the binding decides the scope*. ClusterRoleBinding → every namespace;
RoleBinding (even one pointing at a ClusterRole) → only its own namespace. Deleting the whole binding would also cut off `sync-bot`.
