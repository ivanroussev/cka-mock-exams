# Throwaway Pod running a shell command. The short sleep lets `kubectl run -i` attach before any output is written:
# if a Pod finishes before the attach, its output can be lost and the check would flake.
run_sh() { # run_sh <ctx> <ns> <image> <shell command>
  kubectl --context "$1" -n "$2" run "chk-$RANDOM$RANDOM" --image="$3" --restart=Never --rm -i --quiet \
    --command -- sh -c "sleep 3; $4" 2>/dev/null
}
lookup() { # lookup <name> <expected ip>
  run_sh alt dns-check "$IMG_BUSYBOX" "nslookup -timeout=3 $1" | grep -q "Address:.*$2\$"
}
check "vault.corp.internal resolves to 172.20.50.10" lookup vault.corp.internal 172.20.50.10
check "ldap.corp.internal resolves to 172.20.50.11" lookup ldap.corp.internal 172.20.50.11
check "cluster names still resolve (kubernetes.default)" lookup kubernetes.default.svc.cluster.local "$(kubectl --context alt get svc kubernetes -o jsonpath='{.spec.clusterIP}')"
check "the names are configured in the coredns ConfigMap" bash -c "kubectl --context alt -n kube-system get cm coredns -o jsonpath='{.data}' | grep -q 'vault.corp.internal'"
check "CoreDNS is fully available" deploy_ready alt coredns kube-system
