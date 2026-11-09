node_exec "$ALT_W1" "sed -i 's#^ExecStart=/usr/local/bin/kubelet #ExecStart=/usr/bin/kubelet #' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf && systemctl daemon-reload && systemctl enable kubelet && systemctl restart kubelet"
wait_for 120 node_ready alt "$ALT_W1"
