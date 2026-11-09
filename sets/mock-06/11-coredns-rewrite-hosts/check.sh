retry() { "$@" && return 0; sleep 4; "$@"; }   # in-cluster probes can flake on a loaded laptop
lookup() { kubectl --context main -n data run "chk-$RANDOM$RANDOM" --image="$IMG_BUSYBOX" --restart=Never --rm -i --quiet -- nslookup "$1" 2>/dev/null; }
check "Corefile.bak holds the original CoreDNS configuration" bash -c "f='$ANSWERS/Corefile.bak'; [ -f \"\$f\" ] && grep -q 'kubernetes cluster.local' \"\$f\" && ! grep -q 'legacy.internal' \"\$f\""
check "db.legacy.internal resolves to the ClusterIP of postgres.data" retry bash -c "$(declare -f lookup); ip=\$(kubectl --context main -n data get svc postgres -o jsonpath='{.spec.clusterIP}'); lookup db.legacy.internal | grep -q \"Address: *\$ip\""
check "registry.corp.internal resolves to 10.20.30.40" retry bash -c "$(declare -f lookup); lookup registry.corp.internal | grep -q 'Address: *10.20.30.40'"
check "normal cluster DNS and the CoreDNS deployment are healthy" retry bash -c "$(declare -f lookup); deploy_ready main coredns kube-system 2 && lookup kubernetes.default.svc.cluster.local | grep -q 'Address: *10.96.0.1'"
