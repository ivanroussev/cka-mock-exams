node_exec "$ALT_CP" "set -e
  mv /etc/kubernetes/manifests/kube-apiserver.yaml /root/kube-apiserver.yaml
  etcdutl snapshot restore /opt/etcd-backup/inventory.db --data-dir /var/lib/etcd-restored
  sed -i 's#path: /var/lib/etcd\$#path: /var/lib/etcd-restored#' /etc/kubernetes/manifests/etcd.yaml
  sleep 20
  mv /root/kube-apiserver.yaml /etc/kubernetes/manifests/kube-apiserver.yaml"
wait_api alt 240
wait_for 240 kubectl --context alt -n inventory get configmap price-rules warehouse-map
