cp_ready() { # cp_ready <node>: has the control-plane role and is Ready
  vm_kubectl get nodes -l node-role.kubernetes.io/control-plane -o name | grep -qx "node/$1" &&
  [ "$(vm_kubectl get node "$1" --no-headers | awk '{print $2}')" = Ready ]
}
cps_ready() { cp_ready cp2 && cp_ready cp3; }
etcd3() {
  [ "$(node_exec cp2 'etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt \
        --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key member list 2>/dev/null' \
     | grep -c ', started, ')" = 3 ]
}
apiservers() {
  local n; for n in cp2 cp3; do
    node_exec "$n" "crictl ps --name kube-apiserver -q 2>/dev/null | grep -q . && curl -sk --max-time 5 https://127.0.0.1:6443/livez | grep -q ok" || return 1
  done
}
kubeconfigs() {
  local n; for n in cp2 cp3; do
    node_exec "$n" "grep -q 'server: https://lb:6443' /root/.kube/config && kubectl --kubeconfig /root/.kube/config get --raw /readyz" || return 1
  done
}
check "cp2 and cp3 are Ready control-plane nodes" cps_ready
check "etcd has 3 started members" etcd3
check "kube-apiserver runs and is healthy on cp2 and cp3" apiservers
check "root's /root/.kube/config on cp2 and cp3 talks to lb:6443" kubeconfigs
