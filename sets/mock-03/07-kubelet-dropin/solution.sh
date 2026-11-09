# Retry API calls: on a busy laptop the API server sometimes times out the TLS handshake.
retry() { wait_for 180 "$@"; }
apply() { local f; f=$(mktemp); cat > "$f"; retry kubectl --context "$1" apply -f "$f"; local r=$?; rm -f "$f"; return $r; }
node_exec "$ALT_W1" "rm -f /etc/systemd/system/kubelet.service.d/20-tuning.conf && systemctl daemon-reload && systemctl enable --now kubelet && systemctl restart kubelet"
wait_for 120 node_ready alt "$ALT_W1"
