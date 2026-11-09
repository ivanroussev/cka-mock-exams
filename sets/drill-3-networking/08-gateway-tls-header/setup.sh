# Envoy Gateway on main (GatewayClass eg).
# Workaround: cloud-provider-kind pre-installs the Gateway API CRDs (standard channel) on every cluster, so the plain
# server-side apply in install_gateway_api_crds and the Envoy Gateway chart's own (experimental) Gateway API CRDs both fail.
# Take ownership of the standard CRDs with --force-conflicts and install the chart with --skip-crds instead.
eg_ready() { [ "$(helm --kube-context main -n envoy-gateway-system status eg -o json 2>/dev/null | jq -r .info.status)" = deployed ]; }
install_gateway_api_crds main >/dev/null 2>&1 || kubectl --context main apply --server-side --force-conflicts \
  -f "https://github.com/kubernetes-sigs/gateway-api/releases/download/$GATEWAY_API_VERSION/standard-install.yaml" >/dev/null
eg_ready || install_envoy_gateway main >/dev/null 2>&1
if ! eg_ready; then
  # Envoy's own CRDs (gateway.envoyproxy.io) apply fine; its Gateway API ones are refused by the safe-upgrades policy — expected.
  helm show crds oci://docker.io/envoyproxy/gateway-helm --version "$ENVOY_GATEWAY_VERSION" 2>/dev/null \
    | kubectl --context main apply --server-side --force-conflicts -f - >/dev/null 2>&1
  helm upgrade --install eg oci://docker.io/envoyproxy/gateway-helm --version "$ENVOY_GATEWAY_VERSION" --skip-crds \
    --kube-context main -n envoy-gateway-system --create-namespace --wait --timeout 5m >/dev/null
fi
# Envoy data planes get a ClusterIP Service, so a Gateway's address is its ClusterIP and doesn't depend on the
# cloud provider handing out LoadBalancer IPs (quicker, lighter, and immune to cloud-provider hiccups).
apply main <<'YAML'
apiVersion: gateway.envoyproxy.io/v1alpha1
kind: EnvoyProxy
metadata: {name: clusterip-proxy, namespace: envoy-gateway-system}
spec:
  provider:
    type: Kubernetes
    kubernetes:
      envoyService: {type: ClusterIP}
---
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: eg
spec:
  controllerName: gateway.envoyproxy.io/gatewayclass-controller
  parametersRef: {group: gateway.envoyproxy.io, kind: EnvoyProxy, name: clusterip-proxy, namespace: envoy-gateway-system}
YAML
kubectl --context main wait --for=condition=Accepted gatewayclass/eg --timeout=120s >/dev/null
ns main gw-api
tmp="$(mktemp -d)"
openssl req -x509 -newkey rsa:2048 -nodes -days 365 -subj "/CN=api.example.com" \
  -addext "subjectAltName=DNS:api.example.com" -keyout "$tmp/tls.key" -out "$tmp/tls.crt" >/dev/null 2>&1
kubectl --context main -n gw-api create secret tls api-tls --cert="$tmp/tls.crt" --key="$tmp/tls.key" \
  --dry-run=client -o yaml | kubectl --context main apply -f - >/dev/null
rm -rf "$tmp"
echo_app() { # echo_app <name> <text>
  apply main <<YAML
apiVersion: v1
kind: ConfigMap
metadata: {name: $1-conf, namespace: gw-api}
data:
  default.conf: |
    server { listen 80; location / { default_type text/plain; return 200 "$2"; } }
---
apiVersion: apps/v1
kind: Deployment
metadata: {name: $1, namespace: gw-api}
spec:
  replicas: 1
  selector: {matchLabels: {app: $1}}
  template:
    metadata: {labels: {app: $1}}
    spec:
      containers:
      - name: nginx
        image: $IMG_NGINX
        ports: [{containerPort: 80, name: http}]
        volumeMounts: [{name: conf, mountPath: /etc/nginx/conf.d}]
      volumes: [{name: conf, configMap: {name: $1-conf}}]
---
apiVersion: v1
kind: Service
metadata: {name: $1, namespace: gw-api}
spec:
  selector: {app: $1}
  ports: [{name: http, port: 80, targetPort: http}]
YAML
}
echo_app api-v1 "api v1 stable"
echo_app api-v2 "api v2 canary"
apply main <<'YAML'
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata: {name: api-gw, namespace: gw-api}
spec:
  gatewayClassName: eg
  listeners:
  - {name: http, protocol: HTTP, port: 80}
YAML
for d in api-v1 api-v2; do kubectl --context main -n gw-api rollout status deploy/$d --timeout=120s >/dev/null; done
kubectl --context main -n gw-api wait --for=condition=Programmed gateway/api-gw --timeout=300s >/dev/null
