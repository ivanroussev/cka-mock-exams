node_exec "$ALT_W1" "systemctl disable --now kubelet" >/dev/null 2>&1
wait_for 120 bash -c "! kubectl --context alt get node $ALT_W1 -o jsonpath='{.status.conditions[?(@.type==\"Ready\")].status}' | grep -q True"
