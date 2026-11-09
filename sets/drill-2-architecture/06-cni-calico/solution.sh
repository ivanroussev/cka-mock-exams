install_calico bare
wait_for 180 pod_ready bare probe net-check
wait_for 60 node_exec "$BARE_W1" "ls /etc/cni/net.d/ | grep -q calico"
node_exec "$BARE_W1" "ls /etc/cni/net.d/" | grep -E '\.conflist$' | grep calico | head -1 > "$ANSWERS/cni-config.txt"
