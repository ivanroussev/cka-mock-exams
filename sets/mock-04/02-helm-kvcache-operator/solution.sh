# Retry API calls: on a busy laptop the API server sometimes times out the TLS handshake.
retry() { wait_for 180 "$@"; }
apply() { local f; f=$(mktemp); cat > "$f"; retry kubectl --context "$1" apply -f "$f"; local r=$?; rm -f "$f"; return $r; }
# (retries: helm/kubectl calls can time out on a busy laptop)
wait_for 300 helm --kube-context main upgrade --install kvcache "$FILES/charts/kvcache-operator" -n cache-system --create-namespace \
  --set replicaCount=2 --set logLevel=debug --set watchNamespace=sessions --wait --timeout 3m
printf 'kvcachebackups.cache.example.io\nkvcaches.cache.example.io\n' > "$ANSWERS/kvcache-crds.txt"
cat > "$STATE/.kvcache.yaml" <<'YAML'
apiVersion: cache.example.io/v1beta1
kind: KVCache
metadata: {name: session-store, namespace: sessions}
spec:
  replicas: 3
  memory: 512Mi
  eviction: {policy: allkeys-lru}
YAML
wait_for 120 kubectl --context main apply -f "$STATE/.kvcache.yaml"
