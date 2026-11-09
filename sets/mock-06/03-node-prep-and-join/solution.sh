node_exec "$MAIN_W2" "printf 'overlay\nbr_netfilter\n' > /etc/modules-load.d/k8s.conf
printf 'net.ipv4.ip_forward = 1\nnet.bridge.bridge-nf-call-iptables = 1\nnet.bridge.bridge-nf-call-ip6tables = 1\n' > /etc/sysctl.d/k8s.conf
sysctl --system >/dev/null 2>&1; true"
node_exec "$MAIN_CP" "kubeadm token create --ttl 2h --print-join-command > /root/join-worker.sh"
kubectl --context main -n kube-system get cm kubeadm-config -o jsonpath='{.data.ClusterConfiguration}' | awk '/serviceSubnet:/{print $2}' > "$ANSWERS/service-cidr.txt"
