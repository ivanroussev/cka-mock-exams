# Resolve names from a throwaway busybox pod; prints nslookup output for every name.
lookup() { kubectl --context main -n default run "chk-$RANDOM$RANDOM" --image="$IMG_BUSYBOX" --restart=Never --rm -i --quiet --command -- \
  sh -c "sleep 1; for n in $*; do echo \"== \$n\"; nslookup \$n 2>&1; done" 2>/dev/null; }
export -f lookup
check "pods resolve ledger.corp.internal and git.corp.internal via the corp DNS" bash -c "
  out=\$(lookup ledger.corp.internal. git.corp.internal.); echo \"\$out\" | grep -q 'Address: 10.40.0.21' && echo \"\$out\" | grep -q 'Address: 10.40.0.52'"
check "cluster names still resolve" bash -c "lookup kubernetes.default.svc.cluster.local. | grep -q 'Address: 10.96.0.1'"
check "the corp zone is forwarded in the CoreDNS Corefile (cluster.local block unchanged)" bash -c "
  cf=\$(kubectl --context main -n kube-system get cm coredns -o jsonpath='{.data.Corefile}')
  echo \"\$cf\" | grep -q 'corp.internal' && echo \"\$cf\" | grep -q 'kubernetes cluster.local in-addr.arpa ip6.arpa' && echo \"\$cf\" | grep -q 'forward . /etc/resolv.conf'"
check "vault IP written" file_eq "$ANSWERS/vault-ip.txt" "10.40.0.37"
