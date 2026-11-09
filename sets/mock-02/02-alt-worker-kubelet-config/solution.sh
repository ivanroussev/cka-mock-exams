node_exec "$ALT_W1" "sed -i 's#clientCAFile: /etc/kubernetes/pki/ca.cert#clientCAFile: /etc/kubernetes/pki/ca.crt#' /var/lib/kubelet/config.yaml && systemctl restart kubelet"
wait_for 120 node_ready alt "$ALT_W1"
