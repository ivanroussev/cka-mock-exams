K="kubectl --kubeconfig /etc/kubernetes/admin.conf"
svc_cidr() { [ "$(vm_kubectl get svc kubernetes -n default -o jsonpath='{.spec.clusterIP}')" = 10.112.0.1 ] &&
             vm_kubectl -n kube-system get cm kubeadm-config -o jsonpath='{.data.ClusterConfiguration}' | grep -q 'serviceSubnet: 10.112.0.0/16'; }
pod_cidr() { vm_kubectl -n kube-system get cm kubeadm-config -o jsonpath='{.data.ClusterConfiguration}' | grep -q 'podSubnet: 10.244.0.0/16'; }
flannel()  { [ "$(vm_kubectl -n kube-flannel get ds kube-flannel-ds -o jsonpath='{.status.numberReady}')" = 2 ]; }
both_ready() { vm_kubectl get node w1 >/dev/null && [ "$(vm_kubectl get nodes --no-headers | awk '$2=="Ready"' | wc -l | tr -d ' ')" = 2 ]; }
join_file() {
  node_exec cp1 'grep -qE "^[[:space:]]*(sudo +)?kubeadm join [^ ]+:6443" /root/join-command.txt || exit 1
    t=$(grep -o -- "--token[ =][^ ]*" /root/join-command.txt | head -1 | sed "s/--token[ =]//"); id=${t%%.*}
    [ -n "$id" ] && [ "$('"$K"' -n kube-system get secret bootstrap-token-$id -o jsonpath="{.data.token-secret}" | base64 -d)" = "${t#*.}" ] || exit 1
    h=$(openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed "s/^.* //")
    grep -q -- "--discovery-token-ca-cert-hash[ =]sha256:$h" /root/join-command.txt'
}
check "cluster uses the service CIDR 10.112.0.0/16" svc_cidr
check "cluster uses the pod CIDR 10.244.0.0/16" pod_cidr
check "flannel runs on both nodes" flannel
check "w1 joined and both nodes Ready" both_ready
check "/root/join-command.txt is a valid join command" join_file
