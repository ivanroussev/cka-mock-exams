# Retry API calls: on a busy laptop the API server sometimes times out the TLS handshake.
retry() { wait_for 180 "$@"; }
save() { local f="$1" i=0; shift; while [ $i -lt 36 ]; do "$@" > "$f" 2>/dev/null && [ -s "$f" ] && return 0; i=$((i+1)); sleep 5; done; return 1; }
apply() { local f; f=$(mktemp); cat > "$f"; retry kubectl --context "$1" apply -f "$f"; local r=$?; rm -f "$f"; return $r; }
apply main <<'YAML'
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata: {name: local-retain}
provisioner: rancher.io/local-path
reclaimPolicy: Retain
volumeBindingMode: WaitForFirstConsumer
YAML
save "$STATE/.quorum.yaml" bash -c 'kubectl --context main -n consensus get sts quorum -o yaml'
retry kubectl --context main -n consensus delete sts quorum --wait=true
retry kubectl --context main -n consensus delete pvc data-quorum-0 data-quorum-1 data-quorum-2 --wait=true
sed -e 's/storageClassName: standard/storageClassName: local-retain/' \
    -e '/^  resourceVersion:/d' -e '/^  uid:/d' -e '/^  creationTimestamp:/d' -e '/^status:/,$d' "$STATE/.quorum.yaml" \
  | kubectl --context main apply -f -
kubectl --context main -n consensus rollout status sts/quorum --timeout=300s
