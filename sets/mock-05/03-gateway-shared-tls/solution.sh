kubectl --context main label ns shop-web shared-gw-access=true --overwrite >/dev/null
apply main <<'YAML'
apiVersion: gateway.networking.k8s.io/v1beta1
kind: ReferenceGrant
metadata: {name: gw-infra-certs, namespace: certs}
spec:
  from: [{group: gateway.networking.k8s.io, kind: Gateway, namespace: gw-infra}]
  to: [{group: "", kind: Secret, name: shop-wildcard}]
---
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata: {name: shared-gw, namespace: gw-infra}
spec:
  gatewayClassName: eg
  listeners:
  - name: https
    port: 443
    protocol: HTTPS
    hostname: "*.shop.internal"
    tls:
      mode: Terminate
      certificateRefs: [{kind: Secret, name: shop-wildcard, namespace: certs}]
    allowedRoutes:
      namespaces:
        from: Selector
        selector: {matchLabels: {shared-gw-access: "true"}}
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata: {name: storefront, namespace: shop-web}
spec:
  parentRefs: [{name: shared-gw, namespace: gw-infra, sectionName: https}]
  hostnames: [www.shop.internal]
  rules: [{backendRefs: [{name: storefront, port: 8080}]}]
YAML
kubectl --context main -n gw-infra wait gateway/shared-gw --for=condition=Programmed --timeout=180s >/dev/null
wait_for 90 bash -c "kubectl --context main -n envoy-gateway-system get pods -l gateway.envoyproxy.io/owning-gateway-name=shared-gw -o jsonpath='{.items[*].status.containerStatuses[*].ready}' | grep -qv false"
# wait until the proxy actually serves the route
wait_for 120 bash -c "ip=\$(kubectl --context main -n envoy-gateway-system get svc -l gateway.envoyproxy.io/owning-gateway-name=shared-gw -o jsonpath='{.items[0].spec.clusterIP}'); kubectl --context main -n shop-web run sol-\$RANDOM --image=$IMG_CURL --restart=Never --rm -i --quiet --command -- curl -sk -m 5 --resolve www.shop.internal:443:\$ip https://www.shop.internal/ | grep -q storefront"
