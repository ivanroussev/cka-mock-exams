# Retry API calls: on a busy laptop the API server sometimes times out the TLS handshake.
retry() { wait_for 180 "$@"; }
apply() { local f; f=$(mktemp); cat > "$f"; retry kubectl --context "$1" apply -f "$f"; local r=$?; rm -f "$f"; return $r; }
retry kubectl --context main -n shop expose deploy assets --name=assets --port=8081 --target-port=80
apply main <<'YAML'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata: {name: shop, namespace: shop}
spec:
  ingressClassName: traefik
  rules:
  - host: shop.example.com
    http:
      paths:
      - {path: /api, pathType: Prefix, backend: {service: {name: api, port: {number: 8080}}}}
      - {path: /static, pathType: Prefix, backend: {service: {name: assets, port: {number: 8081}}}}
      - {path: /, pathType: Prefix, backend: {service: {name: web, port: {number: 80}}}}
YAML
wait_for 60 bash -c "kubectl --context main -n shop run sol-\$RANDOM --image=$IMG_CURL --restart=Never --rm -i --quiet --command -- sh -c \"sleep 1; curl -s -m 3 -H 'Host: shop.example.com' http://traefik.traefik/static/x\" | grep -q shop-assets"
