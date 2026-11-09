# Fault 1: kubelet's client CA points at a file that doesn't exist (kubelet exits at start).
# Fault 2: kubelet's kubeconfig points at the wrong API server port (kubelet runs but can't report).
node_exec "$ALT_W1" "sed -i 's#clientCAFile: /etc/kubernetes/pki/ca.crt#clientCAFile: /etc/kubernetes/pki/kubelet-ca.crt#' /var/lib/kubelet/config.yaml
sed -i 's#\(server: https://.*\):6443#\1:6444#' /etc/kubernetes/kubelet.conf
systemctl restart kubelet" >/dev/null 2>&1
wait_for 150 bash -c "! kubectl --context alt get node $ALT_W1 -o jsonpath='{.status.conditions[?(@.type==\"Ready\")].status}' | grep -q True"
