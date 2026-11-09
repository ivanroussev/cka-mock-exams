# Retry API calls: on a busy laptop the API server sometimes times out the TLS handshake.
retry() { wait_for 180 "$@"; }
apply() { local f; f=$(mktemp); cat > "$f"; retry kubectl --context "$1" apply -f "$f"; local r=$?; rm -f "$f"; return $r; }
O="$FILES/invoice-api/overlays/prod"; mkdir -p "$O"
cat > "$O/kustomization.yaml" <<'Y'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: invoice-prod
resources:
- ../../base
- namespace.yaml
labels:
- pairs: {env: prod}
replicas:
- name: invoice-api
  count: 3
patches:
- path: resources.yaml
configMapGenerator:
- name: invoice-api-config
  behavior: merge
  literals:
  - LOG_LEVEL=warn
Y
cat > "$O/namespace.yaml" <<'Y'
apiVersion: v1
kind: Namespace
metadata:
  name: invoice-prod
Y
cat > "$O/resources.yaml" <<'Y'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: invoice-api
spec:
  template:
    spec:
      containers:
      - name: api
        resources:
          requests: {cpu: 250m, memory: 128Mi}
          limits: {memory: 256Mi}
Y
retry kubectl --context main apply -k "$O"
kubectl --context main -n invoice-prod rollout status deploy/invoice-api --timeout=180s
