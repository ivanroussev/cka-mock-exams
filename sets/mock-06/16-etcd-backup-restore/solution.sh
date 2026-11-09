ETC='etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key'
node_exec cp1 "mkdir -p /opt/backup && $ETC snapshot save /opt/backup/pre-cleanup.db"
vm_kubectl delete namespace payments --timeout=180s
# Stop the API server and etcd (static pods), restore, point etcd at the new directory, start them again.
node_exec cp1 'set -e
  IP=$(grep -o -- "--initial-advertise-peer-urls=https://[0-9.]*" /etc/kubernetes/manifests/etcd.yaml | sed "s#.*https://##")
  mkdir -p /root/manifests-off
  mv /etc/kubernetes/manifests/kube-apiserver.yaml /etc/kubernetes/manifests/etcd.yaml /root/manifests-off/
  for i in $(seq 60); do crictl ps -q --name "^(etcd|kube-apiserver)$" | grep -q . || break; sleep 2; done
  etcdutl snapshot restore /opt/backup/pre-cleanup.db --data-dir /var/lib/etcd-restore \
    --name cp1 --initial-cluster cp1=https://$IP:2380 --initial-advertise-peer-urls https://$IP:2380
  sed -i "s#path: /var/lib/etcd\$#path: /var/lib/etcd-restore#" /root/manifests-off/etcd.yaml
  mv /root/manifests-off/etcd.yaml /etc/kubernetes/manifests/
  sleep 10
  mv /root/manifests-off/kube-apiserver.yaml /etc/kubernetes/manifests/'
wait_for 240 vm_kubectl get --raw /readyz
wait_for 120 vm_kubectl get ns payments
# Restart the kubelets so they re-sync pod status with the restored (older) cluster state.
node_exec cp1 "systemctl restart kubelet"; node_exec w1 "systemctl restart kubelet"
wait_for 120 vm_kubectl get --raw /readyz
