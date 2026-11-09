node_exec "$ALT_W1" "sed -i 's#^containerRuntimeEndpoint:.*#containerRuntimeEndpoint: unix:///run/containerd/containerd.sock#' /var/lib/kubelet/config.yaml
systemctl enable --now containerd
systemctl restart kubelet"
wait_for 150 node_ready alt "$ALT_W1"
wait_for 120 bash -c "[ \$(kubectl --context alt -n kube-system get pods --field-selector spec.nodeName=$ALT_W1 -o jsonpath='{range .items[*]}{.status.containerStatuses[0].ready}{\"\\n\"}{end}' | grep -c true) -ge 2 ]"
