# Creating and removing the kind clusters, plus shared add-on installers.

REG_CACHE=cka-registry-cache
CLOUD_PROVIDER=cka-cloud-provider
CLOUD_PROVIDER_IMAGE="registry.k8s.io/cloud-provider-kind/cloud-controller-manager:v0.12.0"

ensure_docker() {
  docker info >/dev/null 2>&1 && return
  info "Starting Docker Desktop…"; open -a Docker
  wait_for 120 docker info || die "Docker isn't running. Start Docker Desktop and try again."
}

# A pull-through cache for Docker Hub, shared by every cluster.
ensure_registry_cache() {
  docker network inspect kind >/dev/null 2>&1 || docker network create kind >/dev/null
  if [ "$(docker inspect -f '{{.State.Running}}' $REG_CACHE 2>/dev/null)" != "true" ]; then
    docker rm -f $REG_CACHE >/dev/null 2>&1
    docker volume create cka-registry-cache >/dev/null
    docker run -d --name $REG_CACHE --restart=always --network kind \
      -e REGISTRY_PROXY_REMOTEURL=https://registry-1.docker.io \
      -v cka-registry-cache:/var/lib/registry registry:2 >/dev/null
  fi
}

# Gives LoadBalancer services an external IP (like a cloud would).
# Gateway API and its default Ingress are turned off: questions install their own controllers, and
# its bundled (older) Gateway API CRDs clash with the newer ones they install.
CLOUD_PROVIDER_ARGS="--gateway-channel=disabled --enable-default-ingress=false"
ensure_cloud_provider() {
  if [ "$(docker inspect -f '{{.State.Running}}' $CLOUD_PROVIDER 2>/dev/null)" = "true" ] &&
     docker inspect -f '{{join .Args " "}}' $CLOUD_PROVIDER 2>/dev/null | grep -q -- "--gateway-channel=disabled"; then
    return
  fi
  docker rm -f $CLOUD_PROVIDER >/dev/null 2>&1
  docker run -d --name $CLOUD_PROVIDER --restart=always --network kind \
    -v /var/run/docker.sock:/var/run/docker.sock $CLOUD_PROVIDER_IMAGE $CLOUD_PROVIDER_ARGS >/dev/null
}
# It caches each cluster's CA, so after clusters are recreated under the same
# names it must be restarted, or LoadBalancer services stay <pending>.
restart_cloud_provider() { docker restart -t 2 $CLOUD_PROVIDER >/dev/null 2>&1 || ensure_cloud_provider; }

kind_config() { # kind_config <name> <workers> <no-cni:0|1>
  local name="$1" workers="$2" nocni="$3" i
  echo "kind: Cluster"
  echo "apiVersion: kind.x-k8s.io/v1alpha4"
  echo "name: $name"
  [ "$nocni" = 1 ] && printf 'networking:\n  disableDefaultCNI: true\n  podSubnet: 192.168.0.0/16\n'
  echo "nodes:"
  echo "- role: control-plane"
  i=0; while [ $i -lt "$workers" ]; do echo "- role: worker"; i=$((i+1)); done
}

# Point a node's containerd at the Docker Hub cache.
configure_mirror() {
  node_exec "$1" "mkdir -p /etc/containerd/certs.d/docker.io && cat > /etc/containerd/certs.d/docker.io/hosts.toml <<EOF
server = \"https://registry-1.docker.io\"
[host.\"http://$REG_CACHE:5000\"]
  capabilities = [\"pull\", \"resolve\"]
EOF"
}

# etcdctl/etcdutl aren't shipped on kind nodes; copy them in so etcd tasks work like the exam.
ETCD_VERSION=v3.6.16
ensure_etcd_tools() {
  local tgz="$CACHE/etcd-$ETCD_VERSION-linux-arm64.tar.gz"
  [ -f "$tgz" ] || curl -sSL -o "$tgz" "https://github.com/etcd-io/etcd/releases/download/$ETCD_VERSION/etcd-$ETCD_VERSION-linux-arm64.tar.gz"
  [ -f "$CACHE/etcdctl" ] || tar -xzf "$tgz" -C "$CACHE" --strip-components=1 "etcd-$ETCD_VERSION-linux-arm64/etcdctl" "etcd-$ETCD_VERSION-linux-arm64/etcdutl"
}

create_cluster() { # create_cluster <short: main|alt|bare>
  local short="$1" name workers nocni node
  case "$short" in
    main) name=$MAIN; workers=2; nocni=0;;
    alt)  name=$ALT;  workers=1; nocni=0;;
    bare) name=$BARE; workers=1; nocni=1;;
    *) die "unknown cluster $short";;
  esac
  kind delete cluster --name "$name" --kubeconfig "$STATE/kc-$short" >/dev/null 2>&1
  kind_config "$name" "$workers" "$nocni" > "$STATE/kind-$short.yaml"
  kind create cluster --config "$STATE/kind-$short.yaml" --image "$KIND_IMAGE" \
    --kubeconfig "$STATE/kc-$short" --wait 0s >"$STATE/kind-$short.log" 2>&1 \
    || { cat "$STATE/kind-$short.log" >&2; die "kind create cluster $name failed"; }
  for node in $(kind get nodes --name "$name"); do
    configure_mirror "$node"
    docker cp "$CACHE/etcdctl" "$node:/usr/local/bin/etcdctl" >/dev/null
    docker cp "$CACHE/etcdutl" "$node:/usr/local/bin/etcdutl" >/dev/null
    node_exec "$node" "cat >> /root/.bashrc <<'EOF'
alias k=kubectl
export KUBECONFIG=/etc/kubernetes/admin.conf
EOF"
  done
  # Rename the context to the short name (main/alt/bare).
  KUBECONFIG="$STATE/kc-$short" kubectl config rename-context "kind-$name" "$short" >/dev/null
}

preload_images() { # pull the common images on every node through the cache
  local name="$1" node img
  for node in $(kind get nodes --name "$name"); do
    for img in $PRELOAD_IMAGES; do
      node_exec "$node" "timeout 300 crictl pull docker.io/$img >/dev/null 2>&1" &
    done
  done
  wait
}

merge_kubeconfigs() {
  local files="" f
  for f in "$STATE"/kc-*; do [ -f "$f" ] && files="$files:$f"; done
  files="${files#:}"
  [ -n "$files" ] || return 0
  KUBECONFIG="$files" kubectl config view --flatten > "$STATE/kubeconfig.tmp" && mv "$STATE/kubeconfig.tmp" "$KUBECONFIG"
  chmod 600 "$KUBECONFIG"
  kubectl config use-context main >/dev/null 2>&1 || true
}

# Create the clusters a set needs, in parallel.
create_clusters() { # create_clusters "main alt"
  ensure_docker; ensure_registry_cache; ensure_cloud_provider; ensure_etcd_tools
  local c pids=""
  for c in $1; do create_cluster "$c" & pids="$pids $!"; done
  for c in $pids; do wait "$c" || die "cluster creation failed"; done
  merge_kubeconfigs
  for c in $1; do
    wait_api "$c" 240 || die "API server for $c never came up"
    [ "$c" = bare ] || kubectl --context "$c" wait --for=condition=Ready nodes --all --timeout=180s >/dev/null
    kubectl --context "$c" -n kube-system rollout status deploy/coredns --timeout=10s >/dev/null 2>&1 || true
  done
  for c in $1; do [ "$c" = bare ] || preload_images "${CKA_ID}-$c"; done
  restart_cloud_provider
}

delete_clusters() {
  local c
  for c in $(kind get clusters 2>/dev/null | grep "^${CKA_ID}-"); do kind delete cluster --name "$c" >/dev/null 2>&1 & done
  wait
  rm -f "$STATE"/kc-* "$KUBECONFIG"
}

# ---------- Shared add-ons (idempotent). Task setup.sh files call these. ----------

METRICS_SERVER_VERSION=v0.9.1
install_metrics_server() { # install_metrics_server <ctx>
  kubectl --context "$1" apply -f "https://github.com/kubernetes-sigs/metrics-server/releases/download/$METRICS_SERVER_VERSION/components.yaml" >/dev/null
  kubectl --context "$1" -n kube-system patch deploy metrics-server --type=json \
    -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]' >/dev/null 2>&1
  kubectl --context "$1" -n kube-system rollout status deploy/metrics-server --timeout=180s >/dev/null
}

GATEWAY_API_VERSION=v1.7.0
# cloud-provider-kind already installs (older) Gateway API CRDs on every cluster,
# so take ownership of them with --force-conflicts.
install_gateway_api_crds() {
  local i
  for i in 1 2 3; do
    kubectl --context "$1" apply --server-side --force-conflicts \
      -f "https://github.com/kubernetes-sigs/gateway-api/releases/download/$GATEWAY_API_VERSION/standard-install.yaml" >/dev/null && return 0
    sleep 5
  done
  warn "Gateway API CRDs failed to install on $1"; return 1
}

ENVOY_GATEWAY_VERSION=v1.10.0
install_envoy_gateway() { # Gateway API controller, GatewayClass "eg"
  local ctx="$1" i
  install_gateway_api_crds "$ctx" || return 1
  # Envoy Gateway's own CRDs only (the chart's Gateway API CRDs would clash with the ones above).
  helm show crds oci://docker.io/envoyproxy/gateway-helm --version "$ENVOY_GATEWAY_VERSION" 2>/dev/null \
    | awk 'BEGIN{RS="\n---"} /group: gateway\.envoyproxy\.io/ {print "---" $0}' \
    | kubectl --context "$ctx" apply --server-side --force-conflicts -f - >/dev/null || return 1
  for i in 1 2; do
    helm upgrade --install eg oci://docker.io/envoyproxy/gateway-helm --version "$ENVOY_GATEWAY_VERSION" \
      --kube-context "$ctx" -n envoy-gateway-system --create-namespace --skip-crds --wait --timeout 5m >/dev/null 2>&1 && break
    [ "$i" = 2 ] && { warn "Envoy Gateway failed to install on $ctx"; return 1; }
    helm uninstall eg --kube-context "$ctx" -n envoy-gateway-system >/dev/null 2>&1
  done
  apply "$ctx" <<'EOF'
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: eg
spec:
  controllerName: gateway.envoyproxy.io/gatewayclass-controller
EOF
  kubectl --context "$ctx" wait --for=condition=Accepted gatewayclass/eg --timeout=120s >/dev/null
}

TRAEFIK_CHART_VERSION=42.3.1
install_traefik() { # Ingress controller, IngressClass "traefik"
  helm repo add traefik https://traefik.github.io/charts >/dev/null 2>&1; helm repo update traefik >/dev/null 2>&1
  local i
  for i in 1 2; do
    helm upgrade --install traefik traefik/traefik --version "$TRAEFIK_CHART_VERSION" --kube-context "$1" \
      -n traefik --create-namespace --set providers.kubernetesGateway.enabled=false --wait --timeout 5m >/dev/null 2>&1 && return 0
    # A release stuck in pending-install (API timeout) blocks the next attempt.
    helm uninstall traefik --kube-context "$1" -n traefik >/dev/null 2>&1
  done
  warn "Traefik failed to install on $1"; return 1
}

CALICO_VERSION=v3.32.3
install_calico() { # install_calico <ctx> — the CNI for clusters without one
  kubectl --context "$1" create -f "https://raw.githubusercontent.com/projectcalico/calico/$CALICO_VERSION/manifests/calico.yaml" >/dev/null 2>&1 || true
  kubectl --context "$1" wait --for=condition=Ready nodes --all --timeout=300s >/dev/null
}
