# Envoy Gateway (GatewayClass eg). Workaround: install_envoy_gateway fails on these clusters because
# cloud-provider-kind already owns the Gateway API CRDs, so fall back to installing EG without its CRD subchart.
eg_accepted() { [ "$(kubectl --context main get gatewayclass eg -o jsonpath='{.status.conditions[?(@.type=="Accepted")].status}' 2>/dev/null)" = True ]; }
install_envoy_gateway main >/dev/null 2>&1 || true
if ! wait_for 30 eg_accepted; then
  d="$(mktemp -d)"
  helm pull oci://docker.io/envoyproxy/gateway-helm --version "$ENVOY_GATEWAY_VERSION" --untar -d "$d" >/dev/null 2>&1
  kubectl --context main apply --server-side -f "$d/gateway-helm/charts/crds/crds/generated/" >/dev/null
  helm upgrade --install eg "$d/gateway-helm" --kube-context main -n envoy-gateway-system --create-namespace \
    --set crds.enabled=false --skip-crds --wait --timeout 5m >/dev/null
  rm -rf "$d"
  apply main <<'YAML'
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata: {name: eg}
spec: {controllerName: gateway.envoyproxy.io/gatewayclass-controller}
YAML
  wait_for 90 eg_accepted
fi
# The shared cloud-provider-kind doesn't reliably hand out LoadBalancer IPs (stale clients after clusters are
# recreated), and Envoy Gateway only marks a Gateway Programmed once it has an address: give the Envoy proxies a ClusterIP Service.
apply main <<'YAML'
apiVersion: gateway.envoyproxy.io/v1alpha1
kind: EnvoyProxy
metadata: {name: cluster-ip, namespace: envoy-gateway-system}
spec:
  provider:
    type: Kubernetes
    kubernetes:
      envoyService: {type: ClusterIP}
YAML
kubectl --context main patch gatewayclass eg --type=merge -p '{"spec":{"parametersRef":{"group":"gateway.envoyproxy.io","kind":"EnvoyProxy","name":"cluster-ip","namespace":"envoy-gateway-system"}}}' >/dev/null

for n in gw-infra certs shop-web blog-web; do ns main $n; done
tmp="$(mktemp -d)"
openssl req -x509 -newkey rsa:2048 -nodes -keyout "$tmp/tls.key" -out "$tmp/tls.crt" -days 365 \
  -subj "/CN=*.shop.internal" -addext "subjectAltName=DNS:*.shop.internal" >/dev/null 2>&1
kubectl --context main -n certs create secret tls shop-wildcard --cert="$tmp/tls.crt" --key="$tmp/tls.key" \
  --dry-run=client -o yaml | kubectl --context main apply -f - >/dev/null
rm -rf "$tmp"
for app in storefront:shop-web blog:blog-web; do
  name="${app%%:*}"; n="${app#*:}"
  apply main <<YAML
apiVersion: apps/v1
kind: Deployment
metadata: {name: $name, namespace: $n}
spec:
  replicas: 1
  selector: {matchLabels: {app: $name}}
  template:
    metadata: {labels: {app: $name}}
    spec:
      containers:
      - name: web
        image: $IMG_BUSYBOX
        command: ["sh", "-c", "mkdir -p /www && echo '$name says hello' > /www/index.html && exec httpd -f -p 8080 -h /www"]
        ports: [{containerPort: 8080}]
---
apiVersion: v1
kind: Service
metadata: {name: $name, namespace: $n}
spec:
  selector: {app: $name}
  ports: [{port: 8080, targetPort: 8080}]
YAML
done
# A team that is NOT allowed on the shared gateway has already pointed a route at it.
apply main <<'YAML'
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata: {name: blog, namespace: blog-web}
spec:
  parentRefs: [{name: shared-gw, namespace: gw-infra}]
  hostnames: [blog.shop.internal]
  rules: [{backendRefs: [{name: blog, port: 8080}]}]
YAML
kubectl --context main -n shop-web rollout status deploy/storefront --timeout=120s >/dev/null
