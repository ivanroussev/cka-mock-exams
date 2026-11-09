# Fault 1: containerd stopped and disabled. Fault 2: kubelet pointed at a CRI socket that doesn't exist (CRI-O's).
node_exec "$ALT_W1" "f=/var/lib/kubelet/config.yaml
if grep -q '^containerRuntimeEndpoint:' \$f; then sed -i 's#^containerRuntimeEndpoint:.*#containerRuntimeEndpoint: unix:///var/run/crio/crio.sock#' \$f
else echo 'containerRuntimeEndpoint: unix:///var/run/crio/crio.sock' >> \$f; fi
systemctl disable --now containerd
systemctl restart kubelet" >/dev/null 2>&1
wait_for 150 bash -c "! kubectl --context alt get node $ALT_W1 -o jsonpath='{.status.conditions[?(@.type==\"Ready\")].status}' | grep -q True"
