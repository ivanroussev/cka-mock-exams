# Retry API calls: on a busy laptop the API server sometimes times out the TLS handshake.
retry() { wait_for 180 "$@"; }
apply() { local f; f=$(mktemp); cat > "$f"; retry kubectl --context "$1" apply -f "$f"; local r=$?; rm -f "$f"; return $r; }
echo kubeconfig > "$ANSWERS/scheduler-volume.txt"
node_exec "$ALT_CP" "sed -i 's#/etc/kubernetes/scheduler-v2.conf#/etc/kubernetes/scheduler.conf#' /etc/kubernetes/manifests/kube-scheduler.yaml"
wait_for 240 deploy_ready alt ledger-sync sync 2
wait_for 60 bash -c "[ \"\$(kubectl --context alt -n kube-system get pod kube-scheduler-$ALT_CP -o jsonpath='{.status.containerStatuses[0].ready}')\" = true ]"
