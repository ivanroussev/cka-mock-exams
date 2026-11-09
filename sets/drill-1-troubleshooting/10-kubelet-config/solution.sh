node_exec "$BARE_W1" "sed -i 's#--config=/var/lib/kubelet/kubelet-config.yaml#--config=/var/lib/kubelet/config.yaml#' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf && systemctl daemon-reload && systemctl enable --now kubelet && systemctl restart kubelet"
wait_for 60 node_exec "$BARE_W1" "curl -sf -m 2 http://127.0.0.1:10248/healthz"
