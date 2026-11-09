via_traefik() { # via_traefik <path…> → one response line per path
  kubectl --context main -n shop run "chk-$RANDOM$RANDOM" --image="$IMG_CURL" --restart=Never --rm -i --quiet --command -- \
    sh -c "sleep 1; for p in $*; do curl -s -m 4 -H 'Host: shop.example.com' http://traefik.traefik\$p; echo; done" 2>/dev/null
}
export -f via_traefik
check "Ingress shop uses the traefik IngressClass" bash -c "
  c=\$(kubectl --context main -n shop get ingress shop -o jsonpath='{.spec.ingressClassName}')
  [ \"\$c\" = traefik ] || { [ -z \"\$c\" ] && [ \"\$(kubectl --context main get ingressclass traefik -o jsonpath='{.metadata.annotations.ingressclass\.kubernetes\.io/is-default-class}')\" = true ]; }"
check "/api and /api/... reach Service api" bash -c "out=\$(via_traefik /api /api/v2/cart); echo \"\$out\" | grep -qx 'shop-api /api' && echo \"\$out\" | grep -qx 'shop-api /api/v2/cart'"
check "Service assets selects the assets pods on port 8081" bash -c "
  [ \"\$(kubectl --context main -n shop get svc assets -o jsonpath='{.spec.ports[0].port}')\" = 8081 ] &&
  [ \$(kubectl --context main -n shop get endpointslices -l kubernetes.io/service-name=assets -o jsonpath='{range .items[*].endpoints[*]}{.addresses[0]}{\"\n\"}{end}' | grep -c .) -ge 1 ] &&
  [ \"\$(kubectl --context main -n shop get endpointslices -l kubernetes.io/service-name=assets -o jsonpath='{.items[0].ports[0].port}')\" = 80 ]"
check "/static/... reaches assets, other paths reach web" bash -c "
  out=\$(via_traefik /static/logo.png /checkout /); echo \"\$out\" | grep -qx 'shop-assets /static/logo.png' &&
  echo \"\$out\" | grep -qx 'shop-web /checkout' && echo \"\$out\" | grep -qx 'shop-web /'"
