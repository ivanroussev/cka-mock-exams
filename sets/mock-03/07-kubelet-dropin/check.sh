check "node $ALT_W1 is Ready" node_ready alt "$ALT_W1"
check "kubelet runs with --config=/var/lib/kubelet/config.yaml" node_exec "$ALT_W1" "systemctl is-active -q kubelet && tr '\0' ' ' < /proc/\$(systemctl show -p MainPID --value kubelet)/cmdline | grep -q -- '--config=/var/lib/kubelet/config.yaml'"
check "kubelet is enabled at boot" node_exec "$ALT_W1" "systemctl is-enabled -q kubelet"
check "kubelet unit has no reference to the missing tuned config" node_exec "$ALT_W1" "! systemctl cat kubelet | grep -v '^#' | grep -q kubelet-tuned.yaml"
