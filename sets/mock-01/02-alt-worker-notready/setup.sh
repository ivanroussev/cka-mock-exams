# The "maintenance" left the kubelet drop-in pointing at a binary path that doesn't exist.
node_exec "$ALT_W1" "sed -i 's#^ExecStart=/usr/bin/kubelet #ExecStart=/usr/local/bin/kubelet #' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf && systemctl daemon-reload && systemctl restart kubelet" >/dev/null 2>&1
wait_for 200 bash -c "! kubectl --context alt get node $ALT_W1 -o jsonpath='{.status.conditions[?(@.type==\"Ready\")].status}' | grep -q True"
