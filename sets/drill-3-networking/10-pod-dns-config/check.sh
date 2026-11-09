SVC_IP="$(kubectl --context main -n dns-lab get svc records -o jsonpath='{.spec.clusterIP}' 2>/dev/null)"
DNS_IP="$(kubectl --context main -n kube-system get svc kube-dns -o jsonpath='{.spec.clusterIP}' 2>/dev/null)"
CACHE_IP="$(kubectl --context main -n dns-lab get pod cache -o jsonpath='{.status.podIP}' 2>/dev/null)"
in_lookup() { kubectl --context main -n dns-lab exec lookup -- "$@" 2>/dev/null; }
resolves() { in_lookup nslookup -timeout=3 records | grep -q "${SVC_IP:-none}"; }
resolv_ok() { local r; r="$(in_lookup cat /etc/resolv.conf)"; contains "$r" "nameserver ${DNS_IP:-none}" && contains "$r" "ndots:2" && contains "$r" "dns-lab.svc.cluster.local"; }
check "lookup uses the cluster DNS with ndots:2" resolv_ok
check "lookup resolves Service records" resolves
check "records-fqdn.txt is correct" bash -c "file_eq '$ANSWERS/records-fqdn.txt' records.dns-lab.svc.cluster.local || file_eq '$ANSWERS/records-fqdn.txt' records.dns-lab.svc.cluster.local."
check "cache-pod-dns.txt is correct" bash -c "file_eq '$ANSWERS/cache-pod-dns.txt' '$(echo "${CACHE_IP:-x}" | tr . -).dns-lab.pod.cluster.local' || file_eq '$ANSWERS/cache-pod-dns.txt' '$(echo "${CACHE_IP:-x}" | tr . -).dns-lab.pod.cluster.local.'"
