node_exec cp1 'mkdir -p /opt/backup &&
  ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 \
    --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key \
    snapshot save /opt/backup/etcd-snapshot.db &&
  etcdutl snapshot status /opt/backup/etcd-snapshot.db -w table > /opt/backup/etcd-snapshot-status.txt'
