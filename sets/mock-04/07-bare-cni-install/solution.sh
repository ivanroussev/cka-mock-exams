# Retry API calls: on a busy laptop the API server sometimes times out the TLS handshake.
retry() { wait_for 180 "$@"; }
save() { local f="$1" i=0; shift; while [ $i -lt 36 ]; do "$@" > "$f" 2>/dev/null && [ -s "$f" ] && return 0; i=$((i+1)); sleep 5; done; return 1; }
apply() { local f; f=$(mktemp); cat > "$f"; retry kubectl --context "$1" apply -f "$f"; local r=$?; rm -f "$f"; return $r; }
save "$ANSWERS/bare-notready.txt" bash -c 'kubectl --context bare get node "$BARE_W1" -o jsonpath='\''{.status.conditions[?(@.type=="Ready")].message}'\'''
kubectl --context bare apply -f "$FILES/calico.yaml" >/dev/null
kubectl --context bare wait --for=condition=Ready nodes --all --timeout=300s
kubectl --context bare -n kube-system rollout status ds/calico-node --timeout=300s
kubectl --context bare -n kube-system rollout status deploy/coredns --timeout=180s
node_exec "$BARE_W1" "ls /etc/cni/net.d/" | grep calico | grep conflist | head -1 > "$ANSWERS/bare-cni-file.txt"
