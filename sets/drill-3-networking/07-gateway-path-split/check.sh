# curl from a throwaway Pod with any curl arguments: curl_in <ctx> <ns> <curl args…>
# (sleep first so `kubectl run -i` attaches before output; retry transient connection errors)
curl_in() {
  local ctx="$1" n="$2" args; shift 2; args="$(printf '%q ' "$@")"
  kubectl --context "$ctx" -n "$n" run "chk-$RANDOM$RANDOM" --image="$IMG_CURL" --restart=Never --rm -i --quiet \
    --command -- sh -c "sleep 3; curl -s -m 5 --retry 3 --retry-all-errors --retry-delay 1 $args" 2>/dev/null
}
GW="$(kubectl --context main -n gw-shop get gateway shop-gw -o jsonpath='{.status.addresses[0].value}' 2>/dev/null)"
GW="${GW:-0.0.0.0}"
route_json() { kubectl --context main -n gw-shop get httproute shop-route -o json; }
export -f curl_in route_json
check "Gateway shop-gw (class eg, HTTP:80, shop.example.com) is Programmed" bash -c "[ \"\$(kubectl --context main -n gw-shop get gateway shop-gw -o jsonpath='{.spec.gatewayClassName} {.spec.listeners[?(@.name==\"http\")].protocol} {.spec.listeners[?(@.name==\"http\")].port} {.spec.listeners[?(@.name==\"http\")].hostname} {.status.conditions[?(@.type==\"Programmed\")].status}')\" = 'eg HTTP 80 shop.example.com True' ]"
check "shop.example.com/cart/… is routed to cart" bash -c "curl_in main gw-shop -H 'Host: shop.example.com' http://$GW/cart/items | grep -q 'cart service'"
check "shop.example.com/ is routed to the store" bash -c "curl_in main gw-shop -H 'Host: shop.example.com' http://$GW/ | grep -q 'store v'"
check "store-v1 / store-v2 weights are 80 / 20" bash -c "route_json | jq -e '([.spec.rules[].backendRefs[]? | select(.name==\"store-v1\") | .weight] == [80]) and ([.spec.rules[].backendRefs[]? | select(.name==\"store-v2\") | .weight] == [20])'"
