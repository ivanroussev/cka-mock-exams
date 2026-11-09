node_exec "$BARE_W1" "sed -i 's#--config=/var/lib/kubelet/config.yaml#--config=/var/lib/kubelet/kubelet-config.yaml#' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf && systemctl daemon-reload && systemctl restart kubelet" >/dev/null 2>&1
wait_for 60 bash -c "! node_exec '$BARE_W1' 'curl -sf -m 2 http://127.0.0.1:10248/healthz'"
