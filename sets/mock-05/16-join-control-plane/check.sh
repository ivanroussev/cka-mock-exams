cp2_cp()    { vm_kubectl get nodes -l node-role.kubernetes.io/control-plane -o name | grep -qx node/cp2 &&
              [ "$(vm_kubectl get node cp2 --no-headers | awk '{print $2}')" = Ready ]; }
etcd2()     { [ "$(node_exec cp1 'etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt \
                 --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key member list 2>/dev/null' \
               | grep ', started, ' | grep -c ', cp[12], ')" = 2 ]; }
apiserver() { node_exec cp2 "crictl ps --name kube-apiserver -q 2>/dev/null | grep -q . && curl -sk --max-time 5 https://127.0.0.1:6443/livez | grep -q ok"; }
label()     { [ "$(vm_kubectl get node cp2 -o jsonpath='{.metadata.labels.tier}')" = control ]; }
check "cp2 is a Ready control-plane node" cp2_cp
check "etcd has members on cp1 and cp2" etcd2
check "kube-apiserver runs and is healthy on cp2" apiserver
check "cp2 is labelled tier=control" label
