wait_api main 180
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

ns main edge; ns main checkout
apply main <<'YAML'
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata: {name: public, namespace: edge}
spec:
  gatewayClassName: eg
  listeners:
  - name: http
    port: 80
    protocol: HTTP
    hostname: "*.example.org"
YAML
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
        image: $IMG_BUSYBOX
        command: ["sh", "-c", "mkdir -p /www && echo 'checkout $v' > /www/index.html && exec httpd -f -p 8080 -h /www"]
        ports: [{containerPort: 8080}]
---
apiVersion: v1
kind: Service
metadata: {name: checkout-$v, namespace: checkout}
spec:
  selector: {app: checkout, version: $v}
  ports: [{port: 80, targetPort: 8080}]
YAML
done
kubectl --context main -n edge wait gateway/public --for=condition=Programmed --timeout=180s >/dev/null
kubectl --context main -n checkout rollout status deploy/checkout-v2 --timeout=120s >/dev/null
