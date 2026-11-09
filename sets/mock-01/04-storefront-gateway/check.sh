source "$TASK_DIR/../lib.sh"
check "Service cart (ClusterIP, port 8080) reaches the cart pods" bash -c "[ \"\$(kubectl --context main -n storefront get svc cart -o jsonpath='{.spec.type}')\" = ClusterIP ] && curl_pod main storefront http://cart.storefront:8080/ | grep -q '^cart'"
# Not the Gateway's own Programmed condition: that also needs a LoadBalancer address from the shared cloud-provider-kind.
check "Gateway shop-gw (class eg, listener http :80, shop.example.test) is accepted and its listener programmed" bash -c "
  [ \"\$(kubectl --context main -n storefront get gateway shop-gw -o jsonpath='{.spec.gatewayClassName}/{.spec.listeners[?(@.name==\"http\")].port}/{.spec.listeners[?(@.name==\"http\")].hostname}')\" = eg/80/shop.example.test ] &&
  [ \"\$(kubectl --context main -n storefront get gateway shop-gw -o jsonpath='{.status.conditions[?(@.type==\"Accepted\")].status}/{.status.listeners[?(@.name==\"http\")].conditions[?(@.type==\"Programmed\")].status}')\" = True/True ]"
check "shop.example.test/cart/... is routed to cart" bash -c "a=\$(gw_addr main storefront shop-gw) && curl_pod main storefront -H 'Host: shop.example.test' http://\$a/cart/items | grep -q '^cart'"
check "shop.example.test/ is routed to catalog" bash -c "a=\$(gw_addr main storefront shop-gw) && curl_pod main storefront -H 'Host: shop.example.test' http://\$a/products/42 | grep -q '^catalog'"
check "route only serves hostname shop.example.test" bash -c "a=\$(gw_addr main storefront shop-gw) && [ \"\$(kubectl --context main -n storefront get httproute shop -o jsonpath='{.spec.hostnames[*]}')\" = shop.example.test ] && ! curl_pod main storefront -H 'Host: other.example.test' http://\$a/ | grep -q catalog"
