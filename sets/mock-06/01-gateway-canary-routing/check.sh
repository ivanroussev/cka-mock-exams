retry() { "$@" && return 0; sleep 4; "$@"; }   # in-cluster probes can flake on a loaded laptop
gw_get() { # gw_get <n> [header] — n requests through the Gateway, prints one body per line
  local ip name="chk-$RANDOM$RANDOM" i out
  ip="$(kubectl --context main -n envoy-gateway-system get svc -l gateway.envoyproxy.io/owning-gateway-name=public,gateway.envoyproxy.io/owning-gateway-namespace=edge -o jsonpath='{.items[0].spec.clusterIP}' 2>/dev/null)"
  [ -n "$ip" ] || return 1
  # run detached and read the logs afterwards (attaching to a short-lived pod can lose output)
  kubectl --context main -n checkout run "$name" --image="$IMG_CURL" --restart=Never --command -- \
    sh -c "for i in \$(seq $1); do curl -s -m 3 ${2:+-H '$2'} -H 'Host: checkout.example.org' http://$ip/; done" >/dev/null 2>&1 || return 1
  for i in $(seq 30); do
    case "$(kubectl --context main -n checkout get pod "$name" -o jsonpath='{.status.phase}' 2>/dev/null)" in Succeeded|Failed) break;; esac; sleep 2
  done
  out="$(kubectl --context main -n checkout logs "$name" 2>/dev/null)"
  kubectl --context main -n checkout delete pod "$name" --wait=false >/dev/null 2>&1
  printf '%s\n' "$out"
}
canary_ok() { local out; out="$(gw_get 6 'X-Canary: always')"; [ "$(printf '%s\n' "$out" | grep -c 'checkout v2')" -ge 5 ] && ! printf '%s\n' "$out" | grep -q 'checkout v1'; }
mostly_v1() { local out; out="$(gw_get 12)"; [ "$(printf '%s\n' "$out" | grep -c 'checkout v')" -ge 10 ] && [ "$(printf '%s\n' "$out" | grep -c 'checkout v1')" -ge 6 ]; }
weights_ok() {
  local w; w="$(kubectl --context main -n checkout get httproute checkout -o jsonpath='{range .spec.rules[*]}{range .backendRefs[*]}{.name}={.weight} {end}{"\n"}{end}' 2>/dev/null)"
  printf '%s\n' "$w" | grep -q 'checkout-v1=90 checkout-v2=10' || printf '%s\n' "$w" | grep -q 'checkout-v2=10 checkout-v1=90'
}
check "HTTPRoute checkout is accepted by Gateway public" bash -c "[ \"\$(kubectl --context main -n checkout get httproute checkout -o jsonpath='{.status.parents[?(@.parentRef.name==\"public\")].conditions[?(@.type==\"Accepted\")].status}')\" = True ]"
check "Gateway public now admits routes from namespace checkout (and still listens on *.example.org:80)" bash -c "[ \"\$(kubectl --context main -n edge get gateway public -o jsonpath='{.spec.listeners[0].port} {.spec.listeners[0].hostname} {.status.listeners[0].attachedRoutes}')\" = '80 *.example.org 1' ]"
check "requests with 'X-Canary: always' always reach checkout-v2" retry canary_ok
check "other requests are split 90/10 between checkout-v1 and checkout-v2" retry bash -c "$(declare -f gw_get weights_ok mostly_v1); weights_ok && mostly_v1"
