KEY=$(node_exec cp1 "kubeadm init phase upload-certs --upload-certs 2>/dev/null | tail -1")
JOIN=$(node_exec cp1 "kubeadm token create --print-join-command --certificate-key $KEY")
node_exec cp2 "$JOIN"
wait_for 240 bash -c "vm_kubectl get node cp2 --no-headers | awk '{print \$2}' | grep -qx Ready"
vm_kubectl label node cp2 tier=control --overwrite
