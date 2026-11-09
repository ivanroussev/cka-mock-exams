node_exec "$ALT_W1" "sed -i 's#clientCAFile: /etc/kubernetes/pki/ca.crt#clientCAFile: /etc/kubernetes/pki/ca.cert#' /var/lib/kubelet/config.yaml && systemctl restart kubelet" >/dev/null 2>&1
wait_for 200 bash -c "! kubectl --context alt get node $ALT_W1 -o jsonpath='{.status.conditions[?(@.type==\"Ready\")].status}' | grep -q True"
