node_exec "$ALT_CP" "mkdir -p /opt/etcd-backup && ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key \
  snapshot save /opt/etcd-backup/pre-upgrade.db"
node_exec "$ALT_CP" "etcdutl snapshot status /opt/etcd-backup/pre-upgrade.db -w json" | sed -n 's/.*"revision":\([0-9]*\).*/\1/p' > "$ANSWERS/etcd-snapshot-revision.txt"
node_exec "$ALT_CP" "cat /etc/kubernetes/pki/apiserver.crt" | openssl x509 -noout -enddate | sed 's/notAfter=//' > "$ANSWERS/apiserver-cert-expiry.txt"
