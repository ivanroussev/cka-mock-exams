node_exec "$ALT_CP" "kubeadm certs check-expiration > /root/cert-expiry.txt 2>&1
kubeadm certs renew apiserver >/dev/null 2>&1
kubeadm certs renew apiserver-kubelet-client >/dev/null 2>&1
crictl stop \$(crictl ps --name kube-apiserver -q) >/dev/null 2>&1"
sleep 10
wait_api alt 180
