check "node $ALT_W1 is Ready" node_ready alt "$ALT_W1"
check "kubelet service is active" node_exec "$ALT_W1" "systemctl is-active kubelet"
check "kubelet is enabled and its unit points at an existing binary" node_exec "$ALT_W1" "systemctl is-enabled kubelet && b=\$(systemctl cat kubelet | grep '^ExecStart=/' | tail -1 | sed 's/^ExecStart=//; s/ .*//') && [ -x \"\$b\" ]"
