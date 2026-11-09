node_exec "$ALT_W1" "sed -i 's#clientCAFile: /etc/kubernetes/pki/kubelet-ca.crt#clientCAFile: /etc/kubernetes/pki/ca.crt#' /var/lib/kubelet/config.yaml
sed -i 's#\(server: https://.*\):6444#\1:6443#' /etc/kubernetes/kubelet.conf
systemctl enable kubelet; systemctl restart kubelet"
wait_for 120 node_ready alt "$ALT_W1"
