check "cp1 is an initialised control-plane node" bash -c \
  "vm_kubectl get nodes -l node-role.kubernetes.io/control-plane -o name | grep -qx node/cp1"
check "pod network CIDR is 10.244.0.0/16" bash -c \
  "vm_kubectl -n kube-system get cm kubeadm-config -o jsonpath='{.data.ClusterConfiguration}' | grep -q 'podSubnet: 10.244.0.0/16'"
check "kubectl works for root with /root/.kube/config" node_exec cp1 \
  "kubectl --kubeconfig /root/.kube/config get --raw /readyz"
check "flannel runs on both nodes" bash -c \
  "[ \"\$(vm_kubectl -n kube-flannel get ds kube-flannel-ds -o jsonpath='{.status.numberReady}')\" = 2 ]"
check "w1 joined and both nodes Ready" bash -c \
  "vm_kubectl get nodes --no-headers | grep -qw w1 && [ \"\$(vm_kubectl get nodes --no-headers | awk '\$2==\"Ready\"' | wc -l | tr -d ' ')\" = 2 ]"
