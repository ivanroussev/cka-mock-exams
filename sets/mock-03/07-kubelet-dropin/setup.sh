node_exec "$ALT_W1" "cat > /etc/systemd/system/kubelet.service.d/20-tuning.conf <<'X'
# perf tuning (TICKET-4471) — use the tuned kubelet profile
[Service]
Environment=\"KUBELET_CONFIG_ARGS=--config=/etc/kubernetes/kubelet-tuned.yaml\"
X
systemctl daemon-reload && systemctl disable kubelet >/dev/null 2>&1; systemctl restart kubelet"
wait_for 150 bash -c "! kubectl --context alt get node $ALT_W1 -o jsonpath='{.status.conditions[?(@.type==\"Ready\")].status}' | grep -q True"
