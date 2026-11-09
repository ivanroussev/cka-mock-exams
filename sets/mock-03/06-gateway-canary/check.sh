# Send n requests (after a short pause: kubectl run -i can miss output printed before it attaches) through the Gateway's Envoy service and print one body per line.
gw_curl() { # gw_curl <n> [extra curl args…]
  local n="$1"; shift
  local svc; svc=$(kubectl --context main -n envoy-gateway-system get svc \
    -l gateway.envoyproxy.io/owning-gateway-name=edge-gw,gateway.envoyproxy.io/owning-gateway-namespace=edge \
    -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
  [ -n "$svc" ] || return 1
  kubectl --context main -n edge run "chk-$RANDOM$RANDOM" --image="$IMG_CURL" --restart=Never --rm -i --quiet --command -- \
    sh -c "sleep 2; i=0; while [ \$i -lt $n ]; do curl -s -m 3 -H 'Host: checkout.shop.example' $* http://$svc.envoy-gateway-system/; i=\$((i+1)); done" 2>/dev/null
}
export -f gw_curl
check "listener http allows routes from namespaces labelled edge-access=true; checkout is labelled" bash -c "
  [ \"\$(kubectl --context main -n edge get gateway edge-gw -o jsonpath='{.spec.listeners[?(@.name==\"http\")].allowedRoutes.namespaces.from}')\" = Selector ] &&
  [ \"\$(kubectl --context main -n edge get gateway edge-gw -o jsonpath='{.spec.listeners[?(@.name==\"http\")].allowedRoutes.namespaces.selector.matchLabels.edge-access}')\" = true ] &&
  [ \"\$(kubectl --context main get ns checkout -o jsonpath='{.metadata.labels.edge-access}')\" = true ]"
check "HTTPRoute checkout is accepted by edge-gw" bash -c "
  [ \"\$(kubectl --context main -n checkout get httproute checkout -o jsonpath='{.status.parents[0].conditions[?(@.type==\"Accepted\")].status}')\" = True ] &&
  kubectl --context main -n checkout get httproute checkout -o jsonpath='{.spec.hostnames}' | grep -q '\"checkout.shop.example\"'"
check "X-Canary: true always reaches checkout-v2" bash -c "
  out=\$(gw_curl 6 -H X-Canary:true); [ \$(printf '%s\n' \"\$out\" | grep -c 'checkout v2') -eq 6 ]"
check "other requests are split 90/10 (weights) and mostly reach checkout-v1" bash -c "
  w=\$(kubectl --context main -n checkout get httproute checkout -o jsonpath='{range .spec.rules[*]}{range .backendRefs[*]}{.name}={.weight} {end}{\"\n\"}{end}' | grep checkout-v1)
  v1=\$(printf '%s' \"\$w\" | tr ' ' '\n' | sed -n 's/^checkout-v1=//p'); v2=\$(printf '%s' \"\$w\" | tr ' ' '\n' | sed -n 's/^checkout-v2=//p')
  [ -n \"\$v1\" ] && [ -n \"\$v2\" ] && [ \"\$v2\" -gt 0 ] && [ \$((v1)) -eq \$((v2 * 9)) ] || exit 1
  out=\$(gw_curl 20); [ \$(printf '%s\n' \"\$out\" | grep -c 'checkout v1') -ge 13 ] && [ \$(printf '%s\n' \"\$out\" | grep -c 'checkout v') -eq 20 ]"
