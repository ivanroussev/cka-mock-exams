check "node $ALT_W1 is Ready" node_ready alt "$ALT_W1"
check "kubelet is enabled at boot" node_exec "$ALT_W1" "systemctl is-enabled kubelet"
