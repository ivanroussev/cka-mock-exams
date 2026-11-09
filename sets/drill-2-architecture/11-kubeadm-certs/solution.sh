# kubeadm reads its config from the cluster; make sure the API answers first (alt may just have been restored).
wait_for 120 node_exec "$ALT_CP" "kubectl --kubeconfig /etc/kubernetes/admin.conf -n kube-system get cm kubeadm-config"
node_exec "$ALT_CP" "kubeadm certs check-expiration" | awk '$1=="ca"{print $2,$3,$4,$5,$6}' > "$ANSWERS/ca-expiry.txt"
sleep 2   # make sure the new expiry differs from the old one even right after cluster creation
node_exec "$ALT_CP" "kubeadm certs renew apiserver"
# Restart the API server so it loads the new certificate (kubelet starts a fresh container).
node_exec "$ALT_CP" "crictl stop \$(crictl ps --name kube-apiserver -q)"
sleep 5
wait_api alt 240
# Leave alt healthy: controller-manager/scheduler restart when the API server goes away.
wait_for 180 bash -c "[ \"\$(kubectl --context alt -n kube-system get pod -l component=kube-controller-manager -o jsonpath='{.items[0].status.conditions[?(@.type==\"Ready\")].status}')\" = True ]"
