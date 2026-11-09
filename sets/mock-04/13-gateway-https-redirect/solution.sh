# Retry API calls: on a busy laptop the API server sometimes times out the TLS handshake.
retry() { wait_for 180 "$@"; }
apply() { local f; f=$(mktemp); cat > "$f"; retry kubectl --context "$1" apply -f "$f"; local r=$?; rm -f "$f"; return $r; }
retry kubectl --context main -n gateway-infra create secret tls secure-shop-tls --cert="$FILES/secure.crt" --key="$FILES/secure.key"
retry kubectl --context main -n gateway-infra patch gateway public-gw --type=json -p='[{"op":"add","path":"/spec/listeners/-","value":
  {"name":"https","protocol":"HTTPS","port":443,"hostname":"secure.shop.example","tls":{"mode":"Terminate","certificateRefs":[{"kind":"Secret","name":"secure-shop-tls"}]}}}]'
apply main <<'YAML'
apiVersion: gateway.networking.k8s.io/v1beta1
kind: ReferenceGrant
metadata: {name: gateway-infra-to-storefront, namespace: shop-web}
spec:
  from:
  - {group: gateway.networking.k8s.io, kind: HTTPRoute, namespace: gateway-infra}
  to:
  - {group: "", kind: Service, name: storefront}
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata: {name: secure-shop, namespace: gateway-infra}
spec:
  parentRefs: [{name: public-gw, sectionName: https}]
  hostnames: [secure.shop.example]
  rules:
  - backendRefs: [{name: storefront, namespace: shop-web, port: 80}]
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata: {name: secure-shop-redirect, namespace: gateway-infra}
spec:
  parentRefs: [{name: public-gw, sectionName: http}]
  hostnames: [secure.shop.example]
  rules:
  - filters:
    - type: RequestRedirect
      requestRedirect: {scheme: https, statusCode: 301}
YAML
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
wait_for 120 bash -c "gw https | grep -q '^200 ' && gw http | grep -q '^301 '"
