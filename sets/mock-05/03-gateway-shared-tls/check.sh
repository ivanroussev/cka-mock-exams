retry() { "$@" && return 0; sleep 4; "$@"; }   # in-cluster probes can flake on a loaded laptop
gw_ip() { kubectl --context main -n envoy-gateway-system get svc -l gateway.envoyproxy.io/owning-gateway-name=shared-gw,gateway.envoyproxy.io/owning-gateway-namespace=gw-infra -o jsonpath='{.items[0].spec.clusterIP}' 2>/dev/null; }
curl_shop() {
  local ip; ip="$(gw_ip)"; [ -n "$ip" ] || return 1
  kubectl --context main -n shop-web run "chk-$RANDOM$RANDOM" --image="$IMG_CURL" --restart=Never --rm -i --quiet \
    --command -- curl -sk -m 5 --resolve "www.shop.internal:443:$ip" https://www.shop.internal/ 2>/dev/null | grep -q "storefront says hello"
}
listener_ok() {
  [ "$(jsonpath main "gateway/shared-gw -n gw-infra" '{.status.listeners[?(@.name=="https")].conditions[?(@.type=="ResolvedRefs")].status}')" = True ] &&
  [ "$(jsonpath main "gateway/shared-gw -n gw-infra" '{.spec.listeners[?(@.name=="https")].port} {.spec.listeners[?(@.name=="https")].protocol} {.spec.listeners[?(@.name=="https")].hostname} {.spec.listeners[?(@.name=="https")].tls.certificateRefs[0].name} {.spec.listeners[?(@.name=="https")].tls.certificateRefs[0].namespace}')" = "443 HTTPS *.shop.internal shop-wildcard certs" ]
}
selector_ok() {
  [ "$(jsonpath main "gateway/shared-gw -n gw-infra" '{.spec.listeners[?(@.name=="https")].allowedRoutes.namespaces.from}')" = Selector ] &&
  [ "$(jsonpath main "ns/shop-web" '{.metadata.labels.shared-gw-access}')" = true ] &&
  [ "$(jsonpath main "ns/blog-web" '{.metadata.labels.shared-gw-access}')" != true ] &&
  [ "$(jsonpath main "httproute/blog -n blog-web" '{.status.parents[0].conditions[?(@.type=="Accepted")].status}')" = False ]
}
check "Gateway shared-gw is Programmed (class eg)" bash -c "[ \"\$(kubectl --context main -n gw-infra get gateway shared-gw -o jsonpath='{.spec.gatewayClassName} {.status.conditions[?(@.type==\"Programmed\")].status}')\" = 'eg True' ]"
check "listener https: 443/HTTPS, *.shop.internal, cert certs/shop-wildcard resolved" listener_ok
check "only labelled namespaces may attach (blog route rejected)" selector_ok
check "HTTPRoute storefront is accepted by shared-gw" bash -c "[ \"\$(kubectl --context main -n shop-web get httproute storefront -o jsonpath='{.status.parents[0].conditions[?(@.type==\"Accepted\")].status}')\" = True ]"
check "https://www.shop.internal/ serves the storefront" retry curl_shop
