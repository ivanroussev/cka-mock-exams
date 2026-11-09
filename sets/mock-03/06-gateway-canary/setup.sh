# cloud-provider-kind pre-installs the Gateway API CRDs with a plain Update, so Helm's server-side apply of the same CRDs
# conflicts. Hand the CRDs over to Helm's field manager first, then install Envoy Gateway.
helm show crds oci://docker.io/envoyproxy/gateway-helm --version "$ENVOY_GATEWAY_VERSION" 2>/dev/null \
  | kubectl --context main apply --server-side --force-conflicts --field-manager=helm -f - >/dev/null
install_envoy_gateway main
ns main edge; ns main checkout
for v in v1 v2; do
apply main <<YAML
apiVersion: apps/v1
kind: Deployment
metadata: {name: checkout-$v, namespace: checkout}
spec:
  replicas: 1
  selector: {matchLabels: {app: checkout, version: $v}}
  template:
    metadata: {labels: {app: checkout, version: $v}}
    spec:
      containers:
      - name: web
        image: $IMG_NGINX
        command: ["sh", "-c", "echo 'checkout $v' > /usr/share/nginx/html/index.html && exec nginx -g 'daemon off;'"]
        ports: [{containerPort: 80}]
---
apiVersion: v1
kind: Service
metadata: {name: checkout-$v, namespace: checkout}
spec:
  selector: {app: checkout, version: $v}
  ports: [{port: 8080, targetPort: 80}]
YAML
done
apply main <<'YAML'
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata: {name: edge-gw, namespace: edge}
spec:
  gatewayClassName: eg
  listeners:
  - name: http
    protocol: HTTP
    port: 80
YAML
kubectl --context main -n edge wait --for=condition=Programmed gateway/edge-gw --timeout=180s >/dev/null
kubectl --context main -n checkout rollout status deploy/checkout-v1 --timeout=120s >/dev/null
kubectl --context main -n checkout rollout status deploy/checkout-v2 --timeout=120s >/dev/null
