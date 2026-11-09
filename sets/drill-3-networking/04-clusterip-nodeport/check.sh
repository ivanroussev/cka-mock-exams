# Throwaway Pod running a shell command. The short sleep lets `kubectl run -i` attach before any output is written:
# if a Pod finishes before the attach, its output can be lost and the check would flake.
run_sh() { # run_sh <ctx> <ns> <image> <shell command>
  kubectl --context "$1" -n "$2" run "chk-$RANDOM$RANDOM" --image="$3" --restart=Never --rm -i --quiet \
    --command -- sh -c "sleep 3; $4" 2>/dev/null
}
export -f run_sh
node_ip() { kubectl --context main get node "$1" -o jsonpath='{.status.addresses[?(@.type=="InternalIP")].address}'; }
check "catalog is a ClusterIP Service on port 8080 with targetPort 'web'" bash -c "[ \"\$(kubectl --context main -n catalog get svc catalog -o jsonpath='{.spec.type} {.spec.ports[0].port} {.spec.ports[0].targetPort}')\" = 'ClusterIP 8080 web' ]"
check "http://catalog.catalog:8080 returns the nginx page" bash -c "run_sh main catalog $IMG_CURL 'curl -s -m 5 --retry 3 --retry-all-errors http://catalog.catalog:8080' | grep -q 'Welcome to nginx'"
check "catalog-ext is a NodePort Service with nodePort 30480 and targetPort 'web'" bash -c "[ \"\$(kubectl --context main -n catalog get svc catalog-ext -o jsonpath='{.spec.type} {.spec.ports[0].port} {.spec.ports[0].nodePort} {.spec.ports[0].targetPort}')\" = 'NodePort 80 30480 web' ]"
check "nginx answers on <node-ip>:30480" bash -c "run_sh main catalog $IMG_CURL 'curl -s -m 5 --retry 3 --retry-all-errors http://$(node_ip "$MAIN_W2"):30480' | grep -q 'Welcome to nginx'"
