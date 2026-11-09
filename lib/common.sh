# Shared settings and helpers. Sourced by the cka CLI and by every task script.
# Must stay compatible with macOS bash 3.2 (no associative arrays, no mapfile).

ROOT="${CKA_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
export CKA_ROOT="$ROOT"

# CKA_ID namespaces everything (kind cluster names, node names, kubeconfig).
# You always use the default "cka". The validator uses other IDs so it can
# run alongside your session without touching it.
export CKA_ID="${CKA_ID:-cka}"
export STATE="$ROOT/.state/$CKA_ID"
export KUBECONFIG="$STATE/kubeconfig"
export ANSWERS="$STATE/answers"   # where the candidate writes answer files
export FILES="$STATE/files"       # input files a task hands the candidate (charts, manifests, kustomize bases)
export K8S_VERSION="${K8S_VERSION:-v1.37.0}"
export KIND_IMAGE="kindest/node:${K8S_VERSION}"
export CACHE="$ROOT/.cache"
mkdir -p "$STATE" "$ANSWERS" "$FILES" "$CACHE"

# Cluster and node names. Contexts are always called main / alt / bare.
export MAIN="${CKA_ID}-main" ALT="${CKA_ID}-alt" BARE="${CKA_ID}-bare"
export MAIN_CP="${MAIN}-control-plane" MAIN_W1="${MAIN}-worker" MAIN_W2="${MAIN}-worker2"
export ALT_CP="${ALT}-control-plane"   ALT_W1="${ALT}-worker"
export BARE_CP="${BARE}-control-plane" BARE_W1="${BARE}-worker"

# Images every cluster pre-pulls through the local cache. Tasks should stick to these.
export IMG_NGINX="nginx:1.27-alpine"
export IMG_NGINX2="nginx:1.28-alpine"
export IMG_BUSYBOX="busybox:1.37"
export IMG_HTTPD="httpd:2.4-alpine"
export IMG_REDIS="redis:7-alpine"
export IMG_CURL="curlimages/curl:8.11.1"
export IMG_POLINUX="polinux/stress:1.0.4"
PRELOAD_IMAGES="$IMG_NGINX $IMG_NGINX2 $IMG_BUSYBOX $IMG_HTTPD $IMG_REDIS $IMG_CURL $IMG_POLINUX"

c_red=$'\033[31m'; c_grn=$'\033[32m'; c_ylw=$'\033[33m'; c_dim=$'\033[2m'; c_b=$'\033[1m'; c_off=$'\033[0m'
say()  { printf '%s\n' "$*" >&2; }
info() { printf '%s›%s %s\n' "$c_dim" "$c_off" "$*" >&2; }
warn() { printf '%s!%s %s\n' "$c_ylw" "$c_off" "$*" >&2; }
die()  { printf '%s✗%s %s\n' "$c_red" "$c_off" "$*" >&2; exit 1; }

# kubectl against a context: kc main get pods
kc() { local ctx="$1"; shift; kubectl --context "$ctx" "$@"; }

# Run a command on a node (kind container or Lima VM) as root.
node_exec() {
  local node="$1"; shift
  if docker inspect "$node" >/dev/null 2>&1; then
    docker exec "$node" bash -c "$*"
  else
    limactl shell "$node" sudo bash -c "$*"
  fi
}
# Copy a local file onto a node.
node_put() { # node_put <node> <local> <remote>
  if docker inspect "$1" >/dev/null 2>&1; then docker cp "$2" "$1:$3" >/dev/null
  else limactl copy "$2" "$1:/tmp/.cka_put" && limactl shell "$1" sudo mv /tmp/.cka_put "$3"; fi
}

# Wait until a command succeeds (default 120s).
wait_for() { # wait_for <seconds> <cmd...>
  local t="$1"; shift; local i=0
  while ! "$@" >/dev/null 2>&1; do i=$((i+2)); [ "$i" -ge "$t" ] && return 1; sleep 2; done
}

# Wait until the API server of a context answers.
wait_api() { wait_for "${2:-180}" kubectl --context "$1" get --raw=/readyz; }

# Apply a YAML heredoc: apply main <<'EOF' ... EOF
apply() { kubectl --context "$1" apply -f - >/dev/null; }

# Make a namespace if missing.
# Waits for its "default" ServiceAccount too, or a Pod created right after can be rejected.
ns() {
  wait_for 60 sh -c "kubectl --context '$1' create namespace '$2' --dry-run=client -o yaml | kubectl --context '$1' apply -f -" || return 1
  wait_for 60 kubectl --context "$1" -n "$2" get serviceaccount default
}
