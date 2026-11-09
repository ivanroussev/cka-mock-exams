check "http://crm-db works from crm-frontend pods" bash -c "kubectl --context main -n crm exec deploy/crm-frontend -- wget -qO- -T 3 http://crm-db | grep -q '^crm-db'"
check "crm-frontend uses the cluster DNS (dnsPolicy ClusterFirst) and is rolled out" bash -c "
  p=\$(kubectl --context main -n crm get deploy crm-frontend -o jsonpath='{.spec.template.spec.dnsPolicy}'); [ \"\$p\" = ClusterFirst ] &&
  [ \"\$(kubectl --context main -n crm get deploy crm-frontend -o jsonpath='{.status.updatedReplicas}/{.status.readyReplicas}/{.spec.template.spec.containers[0].image}')\" = \"2/2/$IMG_NGINX\" ]"
check "FQDN of crm-db written" bash -c "f=\$(tr -d '[:space:]' < '$ANSWERS/crm-db-fqdn.txt'); [ \"\${f%.}\" = crm-db.crm.svc.cluster.local ]"
