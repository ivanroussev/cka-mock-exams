node_exec "$MAIN_W2" "grep -hoE 'unix://[^\" ]+' /var/lib/kubelet/kubeadm-flags.env /var/lib/kubelet/config.yaml 2>/dev/null | head -1" > "$ANSWERS/cri-endpoint.txt"
node_exec "$MAIN_W2" "crictl version" | awk -F': *' '/^RuntimeName/{n=$2} /^RuntimeVersion/{v=$2} END{print n" "v}' > "$ANSWERS/cri-version.txt"
kc main get storageclass archive -o jsonpath='{.provisioner}' > "$ANSWERS/archive-provisioner.txt"
kc main get csidriver "$(cat "$ANSWERS/archive-provisioner.txt")" -o jsonpath='{.spec.attachRequired}' > "$ANSWERS/archive-attach.txt"
