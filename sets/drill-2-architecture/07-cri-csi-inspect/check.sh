# The real values, read from the node itself.
EP=$(node_exec "$MAIN_W2" "grep -hoE 'unix://[^\" ]+' /var/lib/kubelet/kubeadm-flags.env /var/lib/kubelet/config.yaml 2>/dev/null | head -1")
VER=$(node_exec "$MAIN_W2" "crictl version" 2>/dev/null | awk -F': *' '/^RuntimeName/{n=$2} /^RuntimeVersion/{v=$2} END{print n" "v}')
check "cri-endpoint.txt is the kubelet's CRI socket" bash -c "
  a=\$(tr -d '[:space:]' < '$ANSWERS/cri-endpoint.txt') && [ -n '$EP' ] && { [ \"\$a\" = '$EP' ] || [ \"unix://\$a\" = '$EP' ]; }"
check "cri-version.txt is '<RuntimeName> <RuntimeVersion>' from crictl" bash -c "
  [ -n '${VER# }' ] && [ \"\$(tr -s '[:space:]' ' ' < '$ANSWERS/cri-version.txt' | sed 's/^ //;s/ \$//')\" = '$VER' ]"
check "archive-provisioner.txt is files.csi.acme.io" file_eq "$ANSWERS/archive-provisioner.txt" "files.csi.acme.io"
check "archive-attach.txt is false" file_eq "$ANSWERS/archive-attach.txt" "false"
