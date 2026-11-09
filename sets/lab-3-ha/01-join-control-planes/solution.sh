# A fresh certificate key (the uploaded certs expire after 2 hours) and a join command.
KEY=$(node_exec cp1 "kubeadm init phase upload-certs --upload-certs 2>/dev/null | tail -1")
JOIN=$(node_exec cp1 "kubeadm token create --print-join-command")
# Join one at a time: etcd adds one member at a time.
for n in cp2 cp3; do
  node_exec "$n" "$JOIN --control-plane --certificate-key $KEY"
  node_exec "$n" "mkdir -p /root/.kube && cp -f /etc/kubernetes/admin.conf /root/.kube/config"
  wait_for 240 bash -c "vm_kubectl get node $n --no-headers | awk '{print \$2}' | grep -qx Ready"
done
