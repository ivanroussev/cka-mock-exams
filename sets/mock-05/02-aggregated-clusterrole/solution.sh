kubectl --context main label clusterrole monitoring-view-nodes rbac.example.com/aggregate-to-monitorig- rbac.example.com/aggregate-to-monitoring=true --overwrite >/dev/null
kubectl --context main label clusterrole monitoring-debug rbac.example.com/aggregate-to-monitoring- >/dev/null
kubectl --context main create clusterrole monitoring-view-endpoints --verb=get,list,watch --resource=endpointslices.discovery.k8s.io --dry-run=client -o yaml \
  | kubectl --context main label --local -f - rbac.example.com/aggregate-to-monitoring=true -o yaml | kubectl --context main apply -f - >/dev/null
apply main <<'YAML'
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata: {name: monitoring}
aggregationRule:
  clusterRoleSelectors:
  - matchLabels: {rbac.example.com/aggregate-to-monitoring: "true"}
rules: []
YAML
kubectl --context main create clusterrolebinding prom-reader-monitoring --clusterrole=monitoring --serviceaccount=observability:prom-reader >/dev/null
sleep 3
