cordoned() { [ "$(vm_kubectl get node cp1 -o jsonpath='{.spec.unschedulable}')" = true ]; }
cp1_down() {
  node_exec cp1 "! systemctl is-active -q kubelet && [ -z \"\$(crictl ps -q 2>/dev/null)\" ] && ! curl -sk --max-time 3 https://127.0.0.1:6443/livez >/dev/null"
}
via_lb()   { node_exec cp2 "kubectl --kubeconfig /etc/kubernetes/admin.conf --server https://lb:6443 get nodes >/dev/null"; }
holder()   { node_exec cp2 "kubectl --kubeconfig /etc/kubernetes/admin.conf -n kube-system get lease $1 -o jsonpath='{.spec.holderIdentity}'" | cut -d_ -f1; }
leader_ok() { # leader_ok <lease>: the file names the current holder, which is not cp1
  local h; h="$(holder "$1")"
  [ -n "$h" ] && [ "$h" != cp1 ] && node_exec cp2 "grep -qE '^[[:space:]]*$1:[[:space:]]*${h}(_[^[:space:]]*)?[[:space:]]*\$' /root/leaders.txt"
}
check "cp1 is cordoned" cordoned
check "cp1's kubelet and all its containers are stopped" cp1_down
check "the API still answers through lb:6443 from cp2" via_lb
check "/root/leaders.txt names the current kube-scheduler leader" leader_ok kube-scheduler
check "/root/leaders.txt names the current kube-controller-manager leader" leader_ok kube-controller-manager
