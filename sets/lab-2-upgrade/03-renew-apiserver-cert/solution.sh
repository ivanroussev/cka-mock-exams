node_exec cp1 "kubeadm certs check-expiration 2>/dev/null | awk '\$1==\"apiserver\" {print \$2, \$3, \$4, \$5, \$6}' > /root/apiserver-expiry.txt"
node_exec cp1 "kubeadm certs renew apiserver"
# Restart the API server: move its manifest out and back so kubelet recreates the static pod.
node_exec cp1 "mv /etc/kubernetes/manifests/kube-apiserver.yaml /root/ && sleep 20 && mv /root/kube-apiserver.yaml /etc/kubernetes/manifests/"
wait_for 180 vm_kubectl get --raw /readyz
wait_for 60 node_exec cp1 "echo | openssl s_client -connect 127.0.0.1:6443 2>/dev/null | openssl x509 -noout -checkend $((300*86400))"
