# Throwaway Pod running a shell command. The short sleep lets `kubectl run -i` attach before any output is written:
# if a Pod finishes before the attach, its output can be lost and the check would flake.
run_sh() { # run_sh <ctx> <ns> <image> <shell command>
  kubectl --context "$1" -n "$2" run "chk-$RANDOM$RANDOM" --image="$3" --restart=Never --rm -i --quiet \
    --command -- sh -c "sleep 3; $4" 2>/dev/null
}
export -f run_sh
check "legacy-registry has no selector and port 80 → 5000" bash -c "[ \"\$(kubectl --context main -n legacy get svc legacy-registry -o jsonpath='{.spec.selector}|{.spec.ports[0].port}|{.spec.ports[0].targetPort}')\" = '|80|5000' ]"
check "EndpointSlice legacy-registry-1 belongs to the Service and points at the backend" bash -c "kubectl --context main -n legacy get endpointslice legacy-registry-1 -o jsonpath='{.metadata.labels.kubernetes\.io/service-name} {.endpoints[*].addresses[*]} {.ports[*].port}' | grep -q '^legacy-registry .*$(cat "$FILES/legacy-backend.txt").* 5000'"
check "http://legacy-registry.legacy/v2/ returns {}" bash -c "run_sh main legacy $IMG_CURL 'curl -s -m 5 --retry 3 --retry-all-errors http://legacy-registry.legacy/v2/' | grep -qF '{}'"
