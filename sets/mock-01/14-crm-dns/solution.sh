kubectl --context main -n crm patch deploy crm-frontend --type=json -p='[{"op":"replace","path":"/spec/template/spec/dnsPolicy","value":"ClusterFirst"},{"op":"remove","path":"/spec/template/spec/dnsConfig"}]'
kubectl --context main -n crm rollout status deploy/crm-frontend --timeout=120s
echo crm-db.crm.svc.cluster.local > "$ANSWERS/crm-db-fqdn.txt"
