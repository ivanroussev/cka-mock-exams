node_exec "$ALT_W1" "systemctl enable --now kubelet"
wait_for 120 node_ready alt "$ALT_W1"
