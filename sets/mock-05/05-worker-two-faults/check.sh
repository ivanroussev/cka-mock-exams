check "node $ALT_W1 is Ready" node_ready alt "$ALT_W1"
check "kubelet is active and enabled" node_exec "$ALT_W1" "systemctl is-active kubelet && systemctl is-enabled kubelet"
check "kubelet uses the cluster CA as client CA" node_exec "$ALT_W1" "f=\$(awk '/clientCAFile:/{print \$2}' /var/lib/kubelet/config.yaml); [ -f \"\$f\" ] && [ \"\$(md5sum < \"\$f\")\" = \"\$(md5sum < /etc/kubernetes/pki/ca.crt)\" ]"
check "kubelet.conf points at the API server on port 6443" node_exec "$ALT_W1" "grep -q 'server: https://.*:6443\$' /etc/kubernetes/kubelet.conf"
