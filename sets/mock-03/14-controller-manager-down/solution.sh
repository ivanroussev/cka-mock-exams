# Retry API calls: on a busy laptop the API server sometimes times out the TLS handshake.
retry() { wait_for 180 "$@"; }
apply() { local f; f=$(mktemp); cat > "$f"; retry kubectl --context "$1" apply -f "$f"; local r=$?; rm -f "$f"; return $r; }
echo kube-controller-manager.yaml > "$ANSWERS/broken-manifest.txt"
node_exec "$ALT_CP" "sed -i 's#--kubeconfig=/etc/kubernetes/controller-manager.kubeconfig#--kubeconfig=/etc/kubernetes/controller-manager.conf#' /etc/kubernetes/manifests/kube-controller-manager.yaml"
wait_for 240 deploy_ready alt invoicer billing-ops 2
