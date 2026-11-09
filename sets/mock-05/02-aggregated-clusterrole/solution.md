```bash
kubectl get clusterrole --show-labels | grep monitoring
#   monitoring-view-nodes has a typo in its label key (…monitorig); monitoring-debug pulls in secrets+configmaps
kubectl label clusterrole monitoring-view-nodes rbac.example.com/aggregate-to-monitorig- rbac.example.com/aggregate-to-monitoring=true
kubectl label clusterrole monitoring-debug rbac.example.com/aggregate-to-monitoring-

kubectl create clusterrole monitoring-view-endpoints --verb=get,list,watch --resource=endpointslices.discovery.k8s.io
kubectl label clusterrole monitoring-view-endpoints rbac.example.com/aggregate-to-monitoring=true

cat <<'YAML' | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata: {name: monitoring}
aggregationRule:
  clusterRoleSelectors:
  - matchLabels: {rbac.example.com/aggregate-to-monitoring: "true"}
rules: []                     # filled in by the controller manager
YAML
kubectl create clusterrolebinding prom-reader-monitoring --clusterrole=monitoring --serviceaccount=observability:prom-reader

kubectl get clusterrole monitoring -o yaml          # rules now contain pods, nodes, endpointslices — no secrets
SA=system:serviceaccount:observability:prom-reader
kubectl auth can-i list nodes --as $SA; kubectl auth can-i get secrets -A --as $SA   # yes / no
```
Docs: *Using RBAC Authorization → Aggregated ClusterRoles*.
**Pitfalls:** any rules you write into an aggregated ClusterRole are overwritten by the controller. To take permissions *out*,
remove the label from the contributing role — editing `monitoring` itself is undone within seconds.
