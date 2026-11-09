vm_kubectl cordon cp1
node_exec cp1 'systemctl stop kubelet && crictl stop $(crictl ps -q) >/dev/null'
K='kubectl --kubeconfig /etc/kubernetes/admin.conf -n kube-system get lease'
# Leases last 15 s; wait until both have a holder other than cp1.
wait_for 120 node_exec cp2 "$K kube-scheduler -o jsonpath='{.spec.holderIdentity}' | grep -qv '^cp1_' &&
                           $K kube-controller-manager -o jsonpath='{.spec.holderIdentity}' | grep -qv '^cp1_'"
node_exec cp2 "{ echo kube-scheduler: \$($K kube-scheduler -o jsonpath='{.spec.holderIdentity}' | cut -d_ -f1)
                 echo kube-controller-manager: \$($K kube-controller-manager -o jsonpath='{.spec.holderIdentity}' | cut -d_ -f1); } > /root/leaders.txt"
