# Helpers shared by the questions of this set. Sourced by setup/check/solution scripts:
#   source "$TASK_DIR/../lib.sh"

# curl from a throwaway pod. Prints the body. curl_pod <ctx> <ns> <curl args…>
# `kubectl run -i` sometimes loses the output of a container that exits quickly, so retry while it's empty.
curl_pod() {
  local ctx="$1" n="$2" out i; shift 2
  for i in 1 2 3; do
    out="$(kubectl --context "$ctx" -n "$n" run "chk-$RANDOM$RANDOM" --image="$IMG_CURL" --restart=Never --rm -i --quiet \
      --command -- curl -s -m 5 "$@" 2>/dev/null)"
    [ -n "$out" ] && { printf '%s\n' "$out"; return 0; }
  done
  return 1
}
# Same, but runs a shell command (e.g. to capture curl -v on stderr). curl_pod_sh <ctx> <ns> "<shell command>"
# The command starts after 2s: output printed before `kubectl run -i` has attached is lost.
curl_pod_sh() {
  local out i
  for i in 1 2 3; do
    out="$(kubectl --context "$1" -n "$2" run "chk-$RANDOM$RANDOM" --image="$IMG_CURL" --restart=Never --rm -i --quiet \
      --command -- sh -c "sleep 2; $3" 2>/dev/null)"
    [ -n "$out" ] && { printf '%s\n' "$out"; return 0; }
  done
  return 1
}
# curl from a pod with labels, for NetworkPolicy checks. The kindnet policy agent only applies a pod's *egress* rules
# once it knows the pod's IP, so a brand-new pod gets a few seconds of unrestricted egress: wait 4s before connecting.
# curl_as <ctx> <ns> <labels> <url>  → prints the body ("" if blocked)
curl_as() {
  kubectl --context "$1" -n "$2" run "chk-$RANDOM$RANDOM" --image="$IMG_CURL" --restart=Never --rm -i --quiet \
    --labels="$3" --command -- sh -c "sleep 4; curl -s -m 5 '$4'" 2>/dev/null
}
reach_as() { # reach_as <ctx> <ns> <labels> <url> <expected-substring>  (retries, for "must work" checks)
  local i
  for i in 1 2 3; do curl_as "$1" "$2" "$3" "$4" | grep -q -- "$5" && return 0; done
  return 1
}
blocked_as() { # blocked_as <ctx> <ns> <labels> <url> <substring-a-working-answer-would-contain>
  ! curl_as "$1" "$2" "$3" "$4" | grep -q -- "$5"
}
# The in-cluster address of the Envoy proxy Service of a Gateway. gw_addr <ctx> <gw-namespace> <gw-name>
gw_addr() {
  local s
  s="$(kubectl --context "$1" -n envoy-gateway-system get svc \
       -l "gateway.envoyproxy.io/owning-gateway-name=$3,gateway.envoyproxy.io/owning-gateway-namespace=$2" \
       -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)"
  [ -n "$s" ] && echo "$s.envoy-gateway-system.svc.cluster.local"
}
# A tiny nginx config that answers every request with a fixed text (to tell backends apart).
# echo_conf <text> [port]
echo_conf() {
  printf 'server {\n  listen %s;\n  location / {\n    default_type text/plain;\n    return 200 "%s\\n";\n  }\n}\n' "${2:-80}" "$1"
}
# A Deployment + ConfigMap answering with a fixed text: echo_app <ctx> <ns> <name> <text> [port] [extra labels yaml, e.g. "version: v1"]
echo_app() {
  local ctx="$1" n="$2" name="$3" text="$4" port="${5:-80}" extra="${6:-}"
  kubectl --context "$ctx" -n "$n" create configmap "$name-conf" --from-literal=default.conf="$(echo_conf "$text" "$port")" \
    --dry-run=client -o yaml | kubectl --context "$ctx" apply -f - >/dev/null
  kubectl --context "$ctx" apply -f - >/dev/null <<YAML
apiVersion: apps/v1
kind: Deployment
metadata: {name: $name, namespace: $n, labels: {app: $name}}
spec:
  replicas: 1
  selector: {matchLabels: {app: $name}}
  template:
    metadata:
      labels:
        app: $name
        ${extra}
    spec:
      containers:
      - name: web
        image: $IMG_NGINX
        ports: [{containerPort: $port}]
        volumeMounts: [{name: conf, mountPath: /etc/nginx/conf.d}]
      volumes: [{name: conf, configMap: {name: $name-conf}}]
YAML
}

# install_envoy_gateway (lib/clusters.sh) fails on these clusters: cloud-provider-kind already owns the Gateway API CRDs
# (server-side apply field manager "cloud-provider-kind"), so Helm 4's server-side apply hits field conflicts and the
# release is never installed. Same install, plus --force-conflicts, with retries.
ensure_envoy_gateway() { # ensure_envoy_gateway <ctx>
  local i
  for i in 1 2 3; do
    helm upgrade --install eg oci://docker.io/envoyproxy/gateway-helm --version "$ENVOY_GATEWAY_VERSION" \
      --kube-context "$1" -n envoy-gateway-system --create-namespace --force-conflicts --wait --timeout 5m >/dev/null 2>&1 &&
    kubectl --context "$1" -n envoy-gateway-system rollout status deploy/envoy-gateway --timeout=180s >/dev/null 2>&1 && break
    sleep 10
  done
  for i in 1 2 3; do
    kubectl --context "$1" apply -f - >/dev/null 2>&1 <<'YAML' && break
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: eg
spec:
  controllerName: gateway.envoyproxy.io/gatewayclass-controller
YAML
    sleep 5
  done
  kubectl --context "$1" wait gatewayclass/eg --for=condition=Accepted --timeout=120s >/dev/null
}
# install_traefik, but recover from a release left in pending-install (e.g. the API server was slow under load).
ensure_traefik() { # ensure_traefik <ctx>
  local i st
  for i in 1 2 3; do
    st="$(helm --kube-context "$1" -n traefik status traefik -o json 2>/dev/null | sed -n 's/.*"status":"\([a-z-]*\)".*/\1/p' | head -1)"
    case "$st" in pending-*|failed) helm --kube-context "$1" -n traefik uninstall traefik --wait >/dev/null 2>&1;; esac
    install_traefik "$1" >/dev/null 2>&1
    kubectl --context "$1" -n traefik rollout status deploy/traefik --timeout=180s >/dev/null 2>&1 &&
      [ "$(helm --kube-context "$1" -n traefik status traefik -o json 2>/dev/null | sed -n 's/.*"status":"\([a-z-]*\)".*/\1/p' | head -1)" = deployed ] && return 0
    sleep 10
  done
  return 1
}

# Make them usable inside bash -c "…" too.
export -f curl_pod curl_pod_sh curl_as reach_as blocked_as gw_addr echo_conf echo_app ensure_envoy_gateway ensure_traefik
