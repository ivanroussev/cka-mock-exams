kubectl --context main label ns checkout gateway-access=public --overwrite >/dev/null
kubectl --context main -n edge patch gateway public --type=json \
  -p='[{"op":"add","path":"/spec/listeners/0/allowedRoutes","value":{"namespaces":{"from":"Selector","selector":{"matchLabels":{"gateway-access":"public"}}}}}]' >/dev/null
apply main <<'YAML'
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata: {name: checkout, namespace: checkout}
spec:
  parentRefs: [{name: public, namespace: edge}]
  hostnames: [checkout.example.org]
  rules:
  - matches:
    - headers: [{name: X-Canary, value: always}]
    backendRefs: [{name: checkout-v2, port: 80}]
  - backendRefs:
    - {name: checkout-v1, port: 80, weight: 90}
    - {name: checkout-v2, port: 80, weight: 10}
YAML
wait_for 120 bash -c "ip=\$(kubectl --context main -n envoy-gateway-system get svc -l gateway.envoyproxy.io/owning-gateway-name=public -o jsonpath='{.items[0].spec.clusterIP}'); kubectl --context main -n checkout run sol-\$RANDOM --image=$IMG_CURL --restart=Never --rm -i --quiet --command -- curl -s -m 3 -H 'X-Canary: always' -H 'Host: checkout.example.org' http://\$ip/ | grep -q 'checkout v2'"
