# curl through the Gateway's Envoy service; prints "<http_code> <redirect_url> <body>"
gw() { # gw <scheme> [extra curl args]
  local ip; ip=$(kubectl --context main -n envoy-gateway-system get svc \
    -l gateway.envoyproxy.io/owning-gateway-name=public-gw,gateway.envoyproxy.io/owning-gateway-namespace=gateway-infra \
    -o jsonpath='{.items[0].spec.clusterIP}' 2>/dev/null)
  [ -n "$ip" ] || return 1
  local port=80; [ "$1" = https ] && port=443
  kubectl --context main -n gateway-infra run "chk-$RANDOM$RANDOM" --image="$IMG_CURL" --restart=Never --rm -i --quiet --command -- \
    sh -c "sleep 1; curl -sk -m 4 --resolve secure.shop.example:$port:$ip -o /tmp/b -w '%{http_code} %{redirect_url} ' $1://secure.shop.example/; cat /tmp/b" 2>/dev/null
}
export -f gw
L='.spec.listeners[?(@.name=="https")]'
check "TLS Secret secure-shop-tls holds the given certificate" bash -c "
  [ \"\$(kubectl --context main -n gateway-infra get secret secure-shop-tls -o jsonpath='{.type}')\" = kubernetes.io/tls ] &&
  [ \"\$(kubectl --context main -n gateway-infra get secret secure-shop-tls -o jsonpath='{.data.tls\.crt}' | base64 --decode | openssl x509 -noout -fingerprint 2>/dev/null)\" = \"\$(openssl x509 -in '$FILES/secure.crt' -noout -fingerprint)\" ]"
check "listener https: 443/HTTPS, secure.shop.example, terminates with secure-shop-tls" bash -c "
  [ \"\$(kubectl --context main -n gateway-infra get gateway public-gw -o jsonpath='{$L.port} {$L.protocol} {$L.hostname} {$L.tls.mode} {$L.tls.certificateRefs[0].name}')\" = '443 HTTPS secure.shop.example Terminate secure-shop-tls' ] ||
  [ \"\$(kubectl --context main -n gateway-infra get gateway public-gw -o jsonpath='{$L.port} {$L.protocol} {$L.hostname} {$L.tls.mode} {$L.tls.certificateRefs[0].name}')\" = '443 HTTPS secure.shop.example  secure-shop-tls' ]"
check "HTTPS to secure.shop.example reaches storefront (route on https listener, ReferenceGrant for the Service)" bash -c "
  [ \"\$(kubectl --context main -n gateway-infra get httproute secure-shop -o jsonpath='{.spec.parentRefs[0].sectionName}')\" = https ] &&
  kubectl --context main -n shop-web get referencegrant -o jsonpath='{range .items[*]}{.spec.from[*].kind}/{.spec.from[*].namespace}>{.spec.to[*].kind}/{.spec.to[*].name}{\"\n\"}{end}' | grep -qx 'HTTPRoute/gateway-infra>Service/storefront' &&
  gw https | grep -q '^200 .*secure storefront'"
check "plain HTTP answers 301 to https://secure.shop.example/" bash -c "
  [ \"\$(kubectl --context main -n gateway-infra get httproute secure-shop-redirect -o jsonpath='{.spec.parentRefs[0].sectionName}')\" = http ] &&
  gw http | grep -q '^301 https://secure.shop.example/ '"
