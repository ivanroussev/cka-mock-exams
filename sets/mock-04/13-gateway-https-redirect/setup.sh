# cloud-provider-kind pre-installs the Gateway API CRDs with a plain Update, so Helm's server-side apply of the same CRDs
# conflicts. Hand the CRDs over to Helm's field manager first, then install Envoy Gateway.
helm show crds oci://docker.io/envoyproxy/gateway-helm --version "$ENVOY_GATEWAY_VERSION" 2>/dev/null \
  | kubectl --context main apply --server-side --force-conflicts --field-manager=helm -f - >/dev/null
install_envoy_gateway main
ns main gateway-infra; ns main shop-web
openssl req -x509 -newkey rsa:2048 -nodes -days 365 -subj "/CN=secure.shop.example" \
  -addext "subjectAltName=DNS:secure.shop.example" -keyout "$FILES/secure.key" -out "$FILES/secure.crt" 2>/dev/null
apply main <<YAML
apiVersion: apps/v1
kind: Deployment
metadata: {name: storefront, namespace: shop-web}
spec:
  replicas: 1
  selector: {matchLabels: {app: storefront}}
  template:
    metadata: {labels: {app: storefront}}
    spec:
      containers:
      - name: web
        image: $IMG_NGINX
        command: ["sh", "-c", "echo 'secure storefront' > /usr/share/nginx/html/index.html && exec nginx -g 'daemon off;'"]
---
apiVersion: v1
kind: Service
metadata: {name: storefront, namespace: shop-web}
spec:
  selector: {app: storefront}
  ports: [{port: 80}]
---
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata: {name: public-gw, namespace: gateway-infra}
spec:
  gatewayClassName: eg
  listeners:
  - {name: http, protocol: HTTP, port: 80}
YAML
kubectl --context main -n gateway-infra wait --for=condition=Programmed gateway/public-gw --timeout=180s >/dev/null
kubectl --context main -n shop-web rollout status deploy/storefront --timeout=120s >/dev/null
