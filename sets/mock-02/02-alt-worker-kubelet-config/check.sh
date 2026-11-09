check "node $ALT_W1 is Ready" node_ready alt "$ALT_W1"
check "kubelet is active and enabled" node_exec "$ALT_W1" "systemctl is-active kubelet && systemctl is-enabled kubelet"
check "kubelet config points at an existing client CA file" node_exec "$ALT_W1" "f=\$(awk '/clientCAFile:/{print \$2}' /var/lib/kubelet/config.yaml) && [ -s \"\$f\" ]"
