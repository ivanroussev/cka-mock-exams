D="deploy/frontend -n storefront"
DNS=$(kubectl --context main -n kube-system get svc kube-dns -o jsonpath='{.spec.clusterIP}')
check "frontend pods use the cluster DNS server" bash -c "
  deploy_ready main frontend storefront 2 &&
  [ \"\$(kubectl --context main -n storefront exec deploy/frontend -- cat /etc/resolv.conf | grep '^nameserver' | awk '{print \$2}' | tr '\n' ' ')\" = '$DNS ' ]"
check "search domain inventory.svc.cluster.local added via dnsConfig" bash -c "
  kubectl --context main get $D -o jsonpath='{.spec.template.spec.dnsConfig.searches}' | grep -q '\"inventory.svc.cluster.local\"' &&
  kubectl --context main -n storefront exec deploy/frontend -- cat /etc/resolv.conf | grep '^search' | grep -q 'inventory.svc.cluster.local'"
check "frontend reaches the catalog by its short name" bash -c "
  kubectl --context main -n storefront exec deploy/frontend -- curl -s -m 4 http://catalog | grep -q '1204 products' &&
  kubectl --context main -n storefront logs deploy/frontend --since=20s | grep -q '1204 products'"
check "cluster DNS IP written" file_eq "$ANSWERS/cluster-dns-ip.txt" "$DNS"
